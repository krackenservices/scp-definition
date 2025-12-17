# SCP Examples

Comprehensive example `scp.yaml` manifests demonstrating various service patterns and SCP features.

## Examples

### [user-service](./user-service/scp.yaml)
**Tier 2 - Identity & Profile Management**

Demonstrates:
- Multiple REST capabilities with SLAs
- Circuit breaker pattern for auth dependency
- Fallback behavior for cache failures
- PII data classification and GDPR compliance
- Detailed failure modes for database and cache issues

**Key Features:** Authentication integration, data protection, operational constraints

---

### [order-service](./order-service/scp.yaml)
**Tier 1 - Critical Commerce**

Demonstrates:
- High availability SLA (99.99%)
- Event publishing with AsyncAPI contract
- Complex dependency graph (payment, inventory, user, Kafka)
- Queue buffering for payment failures
- Escalation chains for critical service

**Key Features:** Business-critical SLAs, event-driven architecture, PCI compliance

---

### [payment-service](./payment-service/scp.yaml)
**Tier 1 - Payment Processing**

Demonstrates:
- Strict security and compliance (PCI-DSS, mutual TLS)
- External payment gateway integration
- Circuit breaker with failover strategy
- Data inconsistency failure modes
- No deployment windows (always available)

**Key Features:** Maximum security, financial compliance, gateway failover

---

### [analytics-processor](./analytics-processor/scp.yaml)
**Tier 3 - Real-time Data Pipeline**

Demonstrates:
- Stream processing pattern
- Kafka consumer with lag monitoring
- Write-only database dependency
- Optional cache dependency
- Self-healing consumer lag recovery

**Key Features:** Event streaming, data aggregation, async processing

---

### [notification-gateway](./notification-gateway/scp.yaml)
**Tier 2 - Multi-channel Notifications**

Demonstrates:
- Event-driven notification delivery
- Multiple external provider dependencies (SendGrid, Twilio)
- Queue buffering for provider failures
- Rate limiting and retry strategies
- Self-healing rate limit recovery

**Key Features:** Async messaging, multi-channel delivery, resilience patterns

---

### [graphql-gateway](./graphql-gateway/scp.yaml)
**Tier 2 - API Federation**

Demonstrates:
- GraphQL API with schema contract
- Federation pattern (aggregating multiple backends)
- Partial failure handling
- Query complexity limits
- Graceful degradation

**Key Features:** API gateway pattern, schema federation, partial responses

---

### [crowdstrike-edr](./crowdstrike-edr/scp.yaml)
**Tier 1 - Endpoint Security**

Demonstrates:
- Security tool with `x-security` extensions
- Multiple security capabilities (containment, intel, RTR)
- OpenC2-compatible actuator profiles
- External cloud API dependency
- Security-specific failure modes

**Key Features:** SOAR autodiscovery, security automation, threat response

---

## Service Pattern Matrix

| Example | Tier | Domain | Type | Key Pattern |
|---------|------|--------|------|-------------|
| user-service | 2 | identity | REST | Data service with caching |
| order-service | 1 | commerce | REST + Events | Orchestration with events |
| payment-service | 1 | payments | REST + Events | External gateway integration |
| analytics-processor | 3 | analytics | Stream | Real-time data pipeline |
| notification-gateway | 2 | communications | Events | Multi-channel async delivery |
| graphql-gateway | 2 | api-gateway | GraphQL | Federation & aggregation |
| crowdstrike-edr | 1 | security | REST + Events | Security tool with SOAR integration |

## Features Demonstrated

### SLA Targets
- **Availability**: 99.5% to 99.99%
- **Latency**: P99 from 150ms to 500ms
- **Throughput**: 1000-10000 RPS

### Dependency Patterns
- **Circuit breakers**: Prevent cascade failures
- **Queue buffering**: Decouple services
- **Fallback**: Graceful degradation
- **Retry with backoff**: Handle transient failures

### Compliance & Security
- **PCI-DSS**: Payment data protection
- **GDPR**: EU data residency
- **SOC2**: Security controls
- **Data classification**: PII, SENSITIVE, PCI

### Failure Modes
- **Total outage**: Payment gateway down
- **Partial outage**: Inventory service unavailable
- **Degraded experience**: Cache misses, slow queries
- **Data inconsistency**: Database write failures
- **Silent failure**: Event delivery delays

### Security Extensions (x-security)
- **Actuator profiles**: EDR, SIEM, SLPF, SOAR
- **Actions**: query, contain, deny, allow, remediate, notify
- **Targets**: hostname, ipv4_addr, file, process, ioc

## Usage

These examples can be used with the scp-constructor tooling:

```bash
# Validate examples
cd ../../scp-integrations/packages/constructor
uv run scp validate ../../../scp-definition/examples

# Build dependency graph
uv run scp scan ../../../scp-definition/examples --export mermaid
```
