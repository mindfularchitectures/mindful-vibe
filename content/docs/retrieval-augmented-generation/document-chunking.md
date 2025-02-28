---
title: "Document Chunking Strategies"
weight: 30
---

# Document Chunking Strategies for RAG

Document chunking—breaking larger documents into smaller pieces for embedding and retrieval—is critical for effective RAG systems. Proper chunking can dramatically improve retrieval quality and generation relevance.

## Why Chunking Matters

- **Embedding Quality**: Most embedding models have token limits and perform best on coherent, appropriately-sized text chunks
- **Retrieval Precision**: Smaller chunks allow more precise retrieval of relevant information
- **Context Window Management**: Chunks must fit within LLM context windows while providing sufficient information
- **Semantic Coherence**: Chunks should represent coherent units of information

## Basic Chunking Approaches

### Fixed-Size Chunking

Dividing text into chunks with a predefined size:

```python
def fixed_size_chunking(text, chunk_size=1000, overlap=200):
    """Split text into chunks of approximately equal size with overlap."""
    chunks = []
    start = 0
    
    while start < len(text):
        # Find a good breakpoint near the target chunk size
        end = min(start + chunk_size, len(text))
        
        # Try to find a paragraph or sentence break
        if end < len(text):
            # Look for paragraph break
            paragraph_break = text.rfind("\n\n", start, end)
            if paragraph_break > start + 0.5 * chunk_size:
                end = paragraph_break + 2
            else:
                # Look for sentence break (period followed by space)
                sentence_break = text.rfind(". ", start, end)
                if sentence_break > start + 0.5 * chunk_size:
                    end = sentence_break + 2
        
        # Store the chunk
        chunks.append(text[start:end])
        
        # Next start position, with overlap
        start = end - overlap
    
    return chunks
```

### Semantic Chunking

Splitting text based on semantic structure:

```python
def semantic_chunking(document):
    """Split document based on semantic boundaries."""
    # Extract hierarchical structure
    sections = extract_document_sections(document)
    
    chunks = []
    for section in sections:
        # For each major section, create a chunk with relevant metadata
        section_chunk = {
            "text": section.text,
            "metadata": {
                "title": section.title,
                "level": section.level,
                "parent": section.parent_title
            }
        }
        chunks.append(section_chunk)
        
        # If section is too large, split it further
        if len(section.text) > 1500:
            # Split by subsections or paragraphs
            sub_chunks = split_section(section)
            for sub in sub_chunks:
                sub["metadata"]["parent"] = section.title
                chunks.append(sub)
    
    return chunks
```

## Advanced Chunking Strategies

### Recursive Chunking

Hierarchical approach for better handling of nested document structures:

```python
def recursive_chunking(document, max_chunk_size=1000):
    """Recursively chunk a document with hierarchical structure."""
    
    def chunk_section(section, parent_path=""):
        section_chunks = []
        current_path = f"{parent_path}/{section.title}" if parent_path else section.title
        
        # Base case: small enough section
        if len(section.text) <= max_chunk_size:
            section_chunks.append({
                "text": section.text,
                "metadata": {
                    "path": current_path,
                    "title": section.title
                }
            })
            return section_chunks
        
        # Recursive case: further split the section
        if section.subsections:
            # Has explicit subsections
            for subsection in section.subsections:
                section_chunks.extend(chunk_section(subsection, current_path))
        else:
            # No explicit subsections, split by paragraphs
            paragraphs = split_into_paragraphs(section.text)
            current_chunk = {"text": "", "metadata": {"path": current_path, "title": section.title}}
            
            for paragraph in paragraphs:
                if len(current_chunk["text"] + paragraph) > max_chunk_size and current_chunk["text"]:
                    # Store current chunk and start a new one
                    section_chunks.append(current_chunk)
                    current_chunk = {"text": paragraph, "metadata": {"path": current_path, "title": section.title}}
                else:
                    # Add paragraph to current chunk
                    current_chunk["text"] += paragraph
            
            # Add the last chunk if not empty
            if current_chunk["text"]:
                section_chunks.append(current_chunk)
        
        return section_chunks
    
    # Start with the root document
    document_structure = parse_document_structure(document)
    return chunk_section(document_structure)
```

### Hybrid Chunking

Combining multiple chunking strategies for different content types:

```python
def hybrid_chunking(document):
    """Apply different chunking strategies based on document type and content."""
    
    document_type = detect_document_type(document)
    
    if document_type == "technical":
        # For technical documents, preserve code blocks as complete chunks
        chunks = []
        sections = split_by_headings(document)
        
        for section in sections:
            if contains_code_block(section):
                code_chunks = extract_code_chunks(section)
                text_chunks = extract_text_chunks(section)
                chunks.extend(code_chunks)
                chunks.extend(fixed_size_chunking(text_chunks, chunk_size=800))
            else:
                chunks.extend(fixed_size_chunking(section, chunk_size=1000))
    
    elif document_type == "narrative":
        # For narrative content, chunk by semantic units (paragraphs, dialogs)
        chunks = semantic_chunking(document)
    
    else:
        # Default approach
        chunks = fixed_size_chunking(document, chunk_size=1000, overlap=200)
    
    return chunks
```

## Metadata Enrichment

Enhancing chunks with metadata to improve retrieval and context:

```python
def enrich_chunks_with_metadata(chunks, document):
    """Add relevant metadata to chunks for better retrieval and context."""
    
    # Extract document-level metadata
    doc_metadata = extract_document_metadata(document)
    
    # Process each chunk
    for i, chunk in enumerate(chunks):
        # Add document-level metadata
        chunk["metadata"] = {
            "doc_id": doc_metadata["id"],
            "title": doc_metadata["title"],
            "author": doc_metadata["author"],
            "created_at": doc_metadata["created_at"],
            "chunk_id": f"{doc_metadata['id']}-{i}",
            "chunk_index": i,
            "total_chunks": len(chunks)
        }
        
        # Add chunk-specific metadata
        chunk["metadata"].update({
            "char_count": len(chunk["text"]),
            "word_count": len(chunk["text"].split()),
            "embedding_model": "text-embedding-ada-002"  # Record which model created embeddings
        })
        
        # Extract entities from chunk for potential filtering
        chunk["metadata"]["entities"] = extract_entities(chunk["text"])
        
        # Analyze chunk content type
        chunk["metadata"]["content_type"] = detect_content_type(chunk["text"])
    
    return chunks
```

## Chunking Evaluation and Optimization

Metrics and methods for assessing chunking quality:

```python
def evaluate_chunking_strategy(chunks, test_queries, ground_truth, retriever):
    """Evaluate effectiveness of a chunking strategy."""
    results = {}
    
    # Metrics to track
    results["avg_chunk_size"] = sum(len(c["text"]) for c in chunks) / len(chunks)
    results["chunk_count"] = len(chunks)
    results["size_std_dev"] = calculate_std_dev([len(c["text"]) for c in chunks])
    
    # Retrieval evaluation
    recall_scores = []
    precision_scores = []
    
    for query, relevant_docs in zip(test_queries, ground_truth):
        retrieved_chunks = retriever.search(query, chunks, top_k=5)
        retrieved_ids = [chunk["metadata"]["chunk_id"] for chunk in retrieved_chunks]
        
        # Calculate recall: proportion of relevant docs that were retrieved
        relevant_retrieved = len(set(retrieved_ids).intersection(relevant_docs))
        recall = relevant_retrieved / len(relevant_docs) if relevant_docs else 1.0
        recall_scores.append(recall)
        
        # Calculate precision: proportion of retrieved docs that were relevant
        precision = relevant_retrieved / len(retrieved_chunks) if retrieved_chunks else 0.0
        precision_scores.append(precision)
    
    results["avg_recall"] = sum(recall_scores) / len(recall_scores)
    results["avg_precision"] = sum(precision_scores) / len(precision_scores)
    results["f1_score"] = calculate_f1(results["avg_precision"], results["avg_recall"])
    
    return results
```

## Implementation Considerations

- **Document Type Awareness**: Different document types (technical, narrative, etc.) may benefit from different chunking strategies
- **Chunk Size Tuning**: Balance between too small (loses context) and too large (dilutes relevance)
- **Overlap Strategy**: Sufficient overlap prevents information loss at chunk boundaries
- **Processing Overhead**: More sophisticated chunking requires more processing time
- **Metadata Integration**: Enriching chunks with metadata enhances retrieval capabilities

## Related Patterns

- [Basic RAG Implementation]({{< ref "/docs/retrieval-augmented-generation/basic-rag.md" >}})
- [Advanced Retrieval Strategies]({{< ref "/docs/retrieval-augmented-generation/advanced-retrieval.md" >}})
- [Multi-step RAG]({{< ref "/docs/retrieval-augmented-generation/multi-step-rag.md" >}})