---
weight: 20
title: "Retrieval Augmented Generation"
bookCollapseSection: true
---

# Retrieval Augmented Generation (RAG) Patterns

Retrieval Augmented Generation (RAG) is a technique that enhances generative AI outputs by first retrieving relevant information from a knowledge base and then using that information to guide the generation process.

## Why RAG?

RAG addresses several limitations of foundation models:

1. **Knowledge Cutoffs**: Foundation models have knowledge limited to their training data
2. **Hallucinations**: Models may generate plausible but incorrect information
3. **Sourcing**: RAG can provide attribution for generated content
4. **Customization**: Allows models to access domain-specific knowledge without fine-tuning

## Basic RAG Architecture

{{< figure src="/images/rag-architecture.png" title="Basic RAG Architecture" >}}

1. **Document Processing**: Convert documents into chunks and embeddings
2. **Retrieval**: Find relevant information based on the query
3. **Augmented Prompting**: Enhance the prompt with retrieved information
4. **Generation**: Produce the final output using the augmented prompt

## Patterns in this Section

- [Basic RAG Implementation]({{< ref "/docs/retrieval-augmented-generation/basic-rag.md" >}})
- [Advanced Retrieval Strategies]({{< ref "/docs/retrieval-augmented-generation/advanced-retrieval.md" >}})
- [RAG with Document Chunking]({{< ref "/docs/retrieval-augmented-generation/document-chunking.md" >}})
- [Multi-step RAG]({{< ref "/docs/retrieval-augmented-generation/multi-step-rag.md" >}})