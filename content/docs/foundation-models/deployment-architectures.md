---
weight: 2
title: "Model Deployment Architectures"
---

# Model Deployment Architectures

This pattern explores different approaches to deploying foundation models in production environments.

## Pattern Description

Model deployment architectures define how foundation models are hosted, scaled, and made accessible to applications. The right architecture depends on your performance requirements, budget constraints, and operational capabilities.

## Architecture Options

### 1. Cloud API Integration

{{< figure src="/images/cloud-api-architecture.png" title="Cloud API Architecture" >}}

**Description**: Applications connect directly to model providers' APIs (OpenAI, Anthropic, etc.)

**Advantages**:
- No model infrastructure to manage
- Automatic scaling
- Always updated to latest models
- Quick implementation

**Disadvantages**:
- Data leaves your environment
- Higher variable costs at scale
- Limited customization
- Dependency on third-party availability

**When to use**: 
- Rapid prototyping
- Teams with limited ML infrastructure experience
- Variable or unpredictable workloads
- Cases where latest model capabilities are critical

### 2. Self-Hosted Single Instance

**Description**: Deploy open-source models on a single high-powered server or instance.

**Advantages**:
- Complete data control
- Fixed infrastructure costs
- No per-token fees
- Customizable configuration

**Disadvantages**:
- Limited to hardware capacity
- Single point of failure
- Requires ML operations expertise
- May struggle with peak loads

**When to use**:
- Consistent, predictable workloads
- Stringent data privacy requirements
- Budget constraints at higher scales
- Specialized tuning needs

### 3. Self-Hosted Distributed Inference

**Description**: Deploy models across multiple machines using frameworks like vLLM, TGI, or Ray.

**Advantages**:
- Horizontal scalability
- High availability
- Can handle larger batch sizes
- More efficient resource utilization

**Disadvantages**:
- Complex setup and maintenance
- Requires specialized expertise
- Higher fixed infrastructure costs

**When to use**:
- High throughput requirements
- Need for high availability
- Large-scale production deployments

### 4. Hybrid Approach

**Description**: Use a combination of cloud APIs and self-hosted models based on request characteristics.

**Advantages**:
- Cost optimization
- Flexibility to route by importance/complexity
- Graceful fallback options
- Best of both worlds

**Disadvantages**:
- More complex implementation
- Requires maintaining multiple integrations
- Potential consistency issues across models

**When to use**:
- Mixed workloads with varying importance
- Cost-sensitive applications with occasional need for premium capabilities
- Organizations transitioning between approaches

## Implementation Considerations

### Containerization

Using Docker containers for model deployment provides consistency across environments and simplifies scaling.

```dockerfile
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

RUN pip install transformers accelerate vllm

COPY app.py /app/
COPY models /app/models

EXPOSE 8000

CMD ["python", "/app/app.py"]
```

### Autoscaling

For cloud deployments, consider implementing autoscaling based on queue depth or inference latency:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: llm-inference
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: llm-inference
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: External
    external:
      metric:
        name: sqs_queue_length
      target:
        type: AverageValue
        averageValue: 10
```

## Related Patterns

<!-- TODO: Add these files or update references when content is available -->
<!-- - [Model Serving Patterns]({{< ref "/docs/foundation-models/model-serving.md" >}}) -->
<!-- - [API Gateway Pattern]({{< ref "/docs/integration/api-gateway.md" >}}) -->