---
title: "Advanced Retrieval Strategies"
weight: 20
---

# Advanced Retrieval Strategies

While basic RAG implementations use simple vector similarity search, advanced retrieval strategies can significantly improve the quality and relevance of retrieved content.

## Beyond Basic Similarity Search

### Hybrid Search

Combining multiple search techniques to leverage their complementary strengths:

```python
def hybrid_search(query, documents, top_k=5):
    # Get vector similarity results
    vector_results = vector_search(query, documents, top_k=top_k*2)
    
    # Get keyword search results
    keyword_results = keyword_search(query, documents, top_k=top_k*2)
    
    # Combine and deduplicate results
    combined_results = []
    seen_ids = set()
    
    # Interleave results, prioritizing vector matches
    for i in range(max(len(vector_results), len(keyword_results))):
        if i < len(vector_results) and vector_results[i]["id"] not in seen_ids:
            combined_results.append(vector_results[i])
            seen_ids.add(vector_results[i]["id"])
            
        if i < len(keyword_results) and keyword_results[i]["id"] not in seen_ids:
            combined_results.append(keyword_results[i])
            seen_ids.add(keyword_results[i]["id"])
    
    return combined_results[:top_k]
```

### Re-ranking

Apply a second-pass ranking to improve precision:

```python
def rerank_results(query, initial_results, reranker_model):
    # Score each result with a more sophisticated but more expensive model
    scored_results = []
    
    for result in initial_results:
        relevance_score = reranker_model.score(query, result["content"])
        scored_results.append({
            "document": result,
            "score": relevance_score
        })
    
    # Sort by new scores
    reranked_results = sorted(scored_results, key=lambda x: x["score"], reverse=True)
    
    return [item["document"] for item in reranked_results]
```

## Query Transformation Techniques

### Query Expansion

Enriching queries with related terms to improve retrieval:

```python
def expand_query(query, expansion_model):
    # Generate related terms or rephrase the query
    expanded_terms = expansion_model.generate_related_terms(query)
    
    # Combine original query with expansions
    expanded_query = f"{query} {' '.join(expanded_terms)}"
    
    return expanded_query
```

### Query Decomposition

Breaking complex queries into simpler sub-queries:

```python
def decompose_query(complex_query):
    prompt = f"""
    Break down the following complex query into 2-4 simpler sub-queries:
    "{complex_query}"
    
    Output each sub-query on a new line.
    """
    
    sub_queries = llm.generate(prompt).strip().split("\n")
    return [sq.strip() for sq in sub_queries if sq.strip()]
```

## Context-Aware Retrieval

### Conversational Search

Maintaining context across multiple queries:

```python
class ConversationalRetriever:
    def __init__(self, vector_store, history_weight=0.3):
        self.vector_store = vector_store
        self.history_weight = history_weight
        self.conversation_history = []
    
    def retrieve(self, query, top_k=5):
        # Incorporate conversation history into the query
        if self.conversation_history:
            # Create context-aware query
            history_summary = " ".join(self.conversation_history[-3:])  # Last 3 exchanges
            enhanced_query = f"{query} {self.history_weight * history_summary}"
        else:
            enhanced_query = query
        
        # Perform retrieval with enhanced query
        results = self.vector_store.search(enhanced_query, top_k=top_k)
        
        # Update history
        self.conversation_history.append(query)
        
        return results
```

### Knowledge Graph Augmented Retrieval

Using knowledge graphs to enhance retrieval with structural information:

```python
def knowledge_graph_retrieval(query, vector_store, knowledge_graph):
    # Get initial results from vector store
    initial_results = vector_store.search(query, top_k=5)
    
    # Extract entities from the query
    entities = knowledge_graph.extract_entities(query)
    
    # Expand retrieval with related entities
    expanded_results = []
    for entity in entities:
        # Find connected entities in the knowledge graph
        related_entities = knowledge_graph.get_connected_entities(entity, max_distance=2)
        
        # Retrieve documents related to these entities
        for related_entity in related_entities:
            entity_results = vector_store.search(
                f"about {related_entity.name}", top_k=2
            )
            expanded_results.extend(entity_results)
    
    # Combine and deduplicate results
    all_results = initial_results + expanded_results
    deduplicated_results = remove_duplicates(all_results)
    
    return deduplicated_results
```

## Retrieval Efficiency

### Filtering and Faceting

Narrowing search scope with metadata filters:

```python
def filtered_retrieval(query, vector_store, filters):
    """
    Retrieve documents with both semantic search and metadata filters
    
    Example filters:
    {
        "date": {"$gt": "2023-01-01"},
        "category": {"$in": ["technical", "guide"]},
        "author": "Alice"
    }
    """
    results = vector_store.search(
        query, 
        filter=filters, 
        top_k=5
    )
    
    return results
```

### Tiered Retrieval

Using progressively more expensive but accurate retrieval methods:

```python
def tiered_retrieval(query, index):
    # Tier 1: Fast BM25 keyword search to get candidates
    tier1_results = index.keyword_search(query, top_k=100)
    
    # Tier 2: Vector similarity on reduced candidate set
    candidate_ids = [doc.id for doc in tier1_results]
    tier2_results = index.vector_search(
        query, 
        document_ids=candidate_ids, 
        top_k=20
    )
    
    # Tier 3: Rerank with cross-encoder
    tier3_results = index.rerank(query, tier2_results, top_k=5)
    
    return tier3_results
```

## Implementation Considerations

- **Latency vs. Quality**: More sophisticated retrieval often means higher latency
- **Domain Adaptation**: Different domains may benefit from different retrieval strategies
- **Evaluation**: Test multiple strategies with domain-specific evaluation metrics
- **Observability**: Implement logging to understand why certain documents are retrieved

## Related Patterns

- [Basic RAG Implementation]({{< ref "/docs/retrieval-augmented-generation/basic-rag.md" >}})
- [RAG with Document Chunking]({{< ref "/docs/retrieval-augmented-generation/document-chunking.md" >}})
- [Multi-step RAG]({{< ref "/docs/retrieval-augmented-generation/multi-step-rag.md" >}})