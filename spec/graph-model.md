# SCP Architecture Graph Model

This document defines the canonical graph representation derived from SCP manifests.

## Node Types

| Type | Description | Key Properties |
|------|-------------|----------------|
| `System` | A service, application, or component | `urn`, `name`, `tier`, `domain`, `otel_service_name` |
| `Datastore` | Database, cache, or storage | `urn`, `type` (postgres, redis, s3...) |
| `ExternalService` | Third-party service | `urn`, `provider` |
| `Capability` | A provided API or event stream | `id`, `name`, `type`, `sla` |
| `Team` | Owning team | `id`, `name` |

## Edge Types

| Type | From → To | Key Properties |
|------|-----------|----------------|
| `DEPENDS_ON` | System → System/Datastore/External | `type`, `criticality`, `failure_mode`, `declared`, `observed` |
| `PROVIDES` | System → Capability | `sla_availability`, `sla_latency_p99_ms` |
| `OWNS` | Team → System | `escalation_level` |
| `OBSERVED_CALL` | System → System | `call_count_24h`, `error_rate`, `latency_p99_ms` |

## Neo4j Schema

```cypher
// Constraints
CREATE CONSTRAINT system_urn IF NOT EXISTS FOR (s:System) REQUIRE s.urn IS UNIQUE;
CREATE CONSTRAINT capability_id IF NOT EXISTS FOR (c:Capability) REQUIRE c.id IS UNIQUE;
CREATE INDEX otel_idx IF NOT EXISTS FOR (s:System) ON (s.otel_service_name);

// Example: Create system
CREATE (s:System {
  urn: 'urn:scp:acme:payment-service',
  name: 'Payment Service',
  tier: 1,
  domain: 'payments',
  team: 'payments-platform',
  otel_service_name: 'payment-service'
});

// Example: Create dependency
MATCH (from:System {urn: 'urn:scp:acme:payment-service'})
MATCH (to:System {urn: 'urn:scp:acme:user-service'})
CREATE (from)-[:DEPENDS_ON {
  capability: 'user-lookup',
  type: 'rest',
  criticality: 'required',
  failure_mode: 'fail-fast',
  declared: true
}]->(to);
```

## Common Queries

### Blast Radius

```cypher
MATCH (s:System {urn: $urn})<-[:DEPENDS_ON*1..3]-(dependent)
RETURN dependent.urn, dependent.tier, dependent.team
ORDER BY dependent.tier;
```

### All Tier-1 Dependencies

```cypher
MATCH (s:System)-[:DEPENDS_ON {criticality: 'required'}]->(dep)
WHERE s.tier = 1
RETURN s.urn, collect(dep.urn) AS critical_deps;
```

### Undeclared Dependencies (OTel vs SCP)

```cypher
MATCH (a:System)-[obs:OBSERVED_CALL]->(b:System)
WHERE NOT EXISTS {
  MATCH (a)-[dec:DEPENDS_ON]->(b)
  WHERE dec.declared = true
}
RETURN a.urn AS caller, b.urn AS callee, obs.call_count_24h;
```

## Graph Visualization

The graph supports C4-style diagram generation:

```
┌─────────────────────────────────────────────────────────┐
│ Context: Payment Domain                                 │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐     ┌─────────────┐     ┌───────────┐ │
│  │   Payment   │────▶│    User     │────▶│  Users    │ │
│  │   Service   │     │   Service   │     │    DB     │ │
│  │   [Tier 1]  │     │   [Tier 2]  │     │           │ │
│  └─────────────┘     └─────────────┘     └───────────┘ │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐     ┌─────────────┐                   │
│  │   Order     │     │   Stripe    │                   │
│  │   Service   │     │  [External] │                   │
│  │   [Tier 1]  │     │             │                   │
│  └─────────────┘     └─────────────┘                   │
└─────────────────────────────────────────────────────────┘
```
