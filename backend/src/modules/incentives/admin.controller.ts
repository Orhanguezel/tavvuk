// =============================================================
// FILE: src/modules/incentives/admin.controller.ts
// FINAL — Incentives admin controller
// =============================================================

import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';

import {
  adminPlanListQuerySchema,
  adminPlanCreateBodySchema,
  adminPlanPatchBodySchema,
  adminRulesReplaceBodySchema,
  adminLedgerListQuerySchema,
  adminSummaryQuerySchema,
} from './validation';

import {
  adminListPlans as listPlansSvc,
  adminCreatePlanTx,
  adminPatchPlanTx,
  adminGetRules,
  adminReplaceRulesTx,
  adminListLedger as listLedgerSvc,
  adminSummary as summarySvc,
} from './service';

function getAdminId(req: any): string {
  return String(req.user?.sub ?? '');
}

export const adminListPlans: RouteHandler = async (req, reply) => {
  const q = adminPlanListQuerySchema.parse(req.query ?? {});
  const rows = await listPlansSvc(db as any, q);
  return reply.send(rows);
};

export const adminCreatePlan: RouteHandler = async (req, reply) => {
  const adminId = getAdminId(req);
  const body = adminPlanCreateBodySchema.parse(req.body ?? {});
  const isActive = body.is_active == null ? true : !!body.is_active;

  const row = await db.transaction(async (tx: any) => {
    return await adminCreatePlanTx(tx, {
      name: body.name,
      is_active: isActive,
      effective_from: body.effective_from,
      created_by: adminId,
    });
  });

  return reply.code(201).send(row);
};

export const adminPatchPlan: RouteHandler = async (req, reply) => {
  const id = String((req.params as any).id);
  const body = adminPlanPatchBodySchema.parse(req.body ?? {});
  const patch = {
    ...(body.name !== undefined ? { name: body.name } : {}),
    ...(body.is_active !== undefined ? { is_active: !!body.is_active } : {}),
    ...(body.effective_from !== undefined ? { effective_from: body.effective_from } : {}),
  };

  const row = await db.transaction(async (tx: any) => {
    return await adminPatchPlanTx(tx, id, patch as any);
  });

  if (!row) return reply.code(404).send({ error: { message: 'not_found' } });
  return reply.send(row);
};

export const adminGetPlanRules: RouteHandler = async (req, reply) => {
  const id = String((req.params as any).id);
  const rows = await adminGetRules(db as any, id);
  return reply.send(rows);
};

export const adminReplacePlanRules: RouteHandler = async (req, reply) => {
  const id = String((req.params as any).id);
  const body = adminRulesReplaceBodySchema.parse(req.body ?? {});

  await db.transaction(async (tx: any) => {
    await adminReplaceRulesTx(tx, id, {
      rules: body.rules.map((r) => ({
        role_context: r.role_context,
        rule_type: r.rule_type,
        amount: Number(r.amount),
        product_id: r.product_id ?? null,
        is_active: r.is_active == null ? true : !!r.is_active,
      })),
    });
  });

  return reply.send({ ok: true });
};

export const adminListLedger: RouteHandler = async (req, reply) => {
  const q = adminLedgerListQuerySchema.parse(req.query ?? {});
  const rows = await listLedgerSvc(db as any, q);
  return reply.send(rows);
};

export const adminGetSummary: RouteHandler = async (req, reply) => {
  const q = adminSummaryQuerySchema.parse(req.query ?? {});
  const rows = await summarySvc(db as any, q);
  return reply.send(rows);
};
