---
title: "Multi-Step RAG"
weight: 40
---

# Multi-Step RAG

Multi-step Retrieval Augmented Generation (RAG) systems break down the traditional single-pass RAG process into multiple specialized steps, improving accuracy, relevance, and factuality of generated responses.

## Why Multi-Step RAG?

Standard RAG faces several challenges:

- **Query-Document Mismatch**: User queries often don't match the terminology in documents
- **Context Limitations**: Retrieving all necessary information in a single pass is difficult
- **Complex Reasoning**: Some questions require synthesizing information from multiple sources
- **Verification Challenges**: Single-pass RAG lacks built-in fact-checking mechanisms

## Multi-Step RAG Architecture

{{< figure src="/images/multi-step-rag.png" title="Multi-Step RAG Architecture" >}}

## Common Multi-Step RAG Patterns

### Query Rewriting and Decomposition

Breaking down or transforming the original query to improve retrieval:

```python
def multi_step_rag_with_query_transformation(query, knowledge_base, llm):
    # Step 1: Transform the query to improve retrieval
    improved_query = query_rewriter.transform(query)
    
    # Step 2: Decompose into sub-queries if needed
    if is_complex_query(query):
        sub_queries = query_decomposer.decompose(query)
    else:
        sub_queries = [improved_query]
    
    # Step 3: Retrieve information for each sub-query
    all_contexts = []
    for sub_query in sub_queries:
        contexts = knowledge_base.retrieve(sub_query, top_k=3)
        all_contexts.extend(contexts)
    
    # Step 4: Generate response with all retrieved contexts
    prompt = create_rag_prompt(query, all_contexts)
    response = llm.generate(prompt)
    
    return response
```

### Iterative Retrieval

Progressive information gathering through multiple retrieval steps:

```python
def iterative_retrieval_rag(query, knowledge_base, llm, max_iterations=3):
    conversation_history = [{"role": "user", "content": query}]
    retrieved_docs = []
    
    for i in range(max_iterations):
        # Create a prompt for information need identification
        info_need_prompt = f"""
        Based on the original query and our conversation so far, what specific information 
        do we still need to retrieve to answer the question completely?
        
        Original query: {query}
        
        Conversation so far:
        {format_conversation(conversation_history)}
        
        Retrieved information so far:
        {summarize_docs(retrieved_docs)}
        
        Identify the most important information still missing (be specific):
        """
        
        # Generate the next retrieval query
        next_query = llm.generate(info_need_prompt)
        
        # Check if we need more information
        if "no additional information needed" in next_query.lower():
            break
            
        # Retrieve new documents
        new_docs = knowledge_base.retrieve(next_query, top_k=3)
        
        # Filter out documents we've already seen
        new_docs = [doc for doc in new_docs if doc.id not in [d.id for d in retrieved_docs]]
        
        # If no new information is found, stop
        if not new_docs:
            break
            
        # Add new documents to our collection
        retrieved_docs.extend(new_docs)
        
        # Add to conversation history
        conversation_history.append({"role": "assistant", "content": f"I found additional information about: {next_query}"})
    
    # Final response generation with all retrieved information
    final_prompt = create_rag_prompt(query, retrieved_docs)
    response = llm.generate(final_prompt)
    
    return response
```

### Retrieve-Then-Read

Separating retrieval from reading for better context management:

```python
def retrieve_then_read(query, knowledge_base, llm):
    # Step 1: Retrieve relevant documents
    documents = knowledge_base.retrieve(query, top_k=10)
    
    # Step 2: Rank documents by relevance with a more powerful model
    ranked_documents = rerank_documents(query, documents)
    
    # Step 3: Select top documents that fit within context window
    selected_docs = select_documents_for_context(ranked_documents, max_tokens=6000)
    
    # Step 4: Generate a comprehensive answer based on selected documents
    prompt = f"""
    Question: {query}
    
    Please answer the question based on the following information:
    
    {format_documents(selected_docs)}
    
    Answer:
    """
    
    response = llm.generate(prompt)
    return response
```

### Generate-Then-Retrieve (Hypothetical Document Reasoning)

Generating a hypothetical answer before seeking verification:

```python
def generate_then_retrieve(query, knowledge_base, llm):
    # Step 1: Generate a hypothetical answer
    hypothetical_prompt = f"""
    Question: {query}
    
    Please generate a detailed, comprehensive answer to this question using your knowledge.
    Include specific details, facts, and information that would need verification.
    """
    
    hypothetical_answer = llm.generate(hypothetical_prompt)
    
    # Step 2: Extract factual claims from the hypothetical answer
    claims_prompt = f"""
    Extract 3-5 specific factual claims from this answer that should be verified:
    
    {hypothetical_answer}
    
    List each claim on a separate line, focusing on factual statements only.
    """
    
    claims = llm.generate(claims_prompt).strip().split("\n")
    
    # Step 3: Retrieve evidence for each claim
    evidence = {}
    for claim in claims:
        claim_docs = knowledge_base.retrieve(claim, top_k=3)
        evidence[claim] = claim_docs
    
    # Step 4: Revise the answer based on evidence
    revision_prompt = f"""
    Original question: {query}
    
    Your initial answer: {hypothetical_answer}
    
    Here is evidence for key claims in your answer:
    
    {format_evidence(evidence)}
    
    Please revise your answer to ensure factual accuracy based on the evidence.
    Where evidence contradicts your claims, correct them.
    Where evidence is missing, acknowledge uncertainty.
    Where evidence confirms your claims, you may elaborate further.
    """
    
    revised_answer = llm.generate(revision_prompt)
    
    return {
        "final_answer": revised_answer,
        "evidence": evidence
    }
```

### Self-Critique and Refinement

Adding a verification step to improve factual accuracy:

```python
def rag_with_self_critique(query, knowledge_base, llm):
    # Step 1: Standard RAG retrieval and generation
    documents = knowledge_base.retrieve(query, top_k=5)
    initial_prompt = create_rag_prompt(query, documents)
    initial_answer = llm.generate(initial_prompt)
    
    # Step 2: Self-critique
    critique_prompt = f"""
    Original question: {query}
    
    Your answer: {initial_answer}
    
    Please critique this answer on the following dimensions:
    1. Factual accuracy - Are there statements not supported by the retrieved documents?
    2. Completeness - Does the answer address all aspects of the question?
    3. Relevance - Is all information in the answer relevant to the question?
    4. Logical consistency - Are there any contradictions or logical errors?
    
    For each issue identified, cite the specific part of the answer that needs improvement.
    """
    
    critique = llm.generate(critique_prompt)
    
    # Step 3: Additional targeted retrieval based on critique
    retrieval_prompt = f"""
    Based on the following critique of an answer, what additional information 
    should we retrieve to improve the answer?
    
    Question: {query}
    Critique: {critique}
    
    List up to 3 specific queries we should make to find missing or corrective information.
    """
    
    additional_queries = llm.generate(retrieval_prompt).strip().split("\n")
    additional_docs = []
    
    for additional_query in additional_queries:
        docs = knowledge_base.retrieve(additional_query, top_k=2)
        additional_docs.extend(docs)
    
    # Step 4: Generate improved answer
    refinement_prompt = f"""
    Original question: {query}
    
    Your initial answer: {initial_answer}
    
    Your self-critique: {critique}
    
    Additional information:
    {format_documents(additional_docs)}
    
    Please provide an improved, refined answer that addresses the issues identified 
    in your self-critique and incorporates any relevant additional information.
    """
    
    refined_answer = llm.generate(refinement_prompt)
    
    return refined_answer
```

## Advanced Multi-Step RAG Patterns

### Recursive Retrieval and Reasoning

Building a recursive tree of evidence for complex queries:

```python
def recursive_retrieve_and_reason(query, knowledge_base, llm, max_depth=3):
    def recursive_step(query, depth=0):
        if depth >= max_depth:
            return {"reasoning": "Reached maximum recursion depth", "evidence": []}
        
        # Retrieve initial information
        documents = knowledge_base.retrieve(query, top_k=3)
        
        # Initial reasoning based on retrieved information
        reasoning_prompt = f"""
        Question: {query}
        
        Based on the following information:
        {format_documents(documents)}
        
        Provide your reasoning about the question, and identify any remaining questions 
        that need to be answered to fully address the original question.
        
        Format:
        Reasoning: <your reasoning based on current information>
        Remaining questions: <list each question on a separate line or state "No further questions">
        """
        
        reasoning_output = llm.generate(reasoning_prompt)
        
        # Extract reasoning and remaining questions
        reasoning_parts = reasoning_output.split("Remaining questions:")
        reasoning = reasoning_parts[0].replace("Reasoning:", "").strip()
        
        # Check if we have remaining questions
        if len(reasoning_parts) > 1 and "No further questions" not in reasoning_parts[1]:
            remaining_questions = [q.strip() for q in reasoning_parts[1].split("\n") if q.strip()]
            
            # Recursively answer remaining questions
            sub_results = []
            for sub_query in remaining_questions:
                sub_result = recursive_step(sub_query, depth + 1)
                sub_results.append({
                    "question": sub_query,
                    "result": sub_result
                })
            
            return {
                "reasoning": reasoning,
                "evidence": documents,
                "sub_questions": sub_results
            }
        else:
            return {
                "reasoning": reasoning,
                "evidence": documents
            }
    
    # Start recursive process
    result_tree = recursive_step(query)
    
    # Final synthesis
    synthesis_prompt = f"""
    Synthesize a comprehensive answer to the question: "{query}"
    
    Based on the following reasoning and evidence tree:
    {format_result_tree(result_tree)}
    
    Provide a clear, complete, and well-structured answer.
    """
    
    final_answer = llm.generate(synthesis_prompt)
    
    return {
        "answer": final_answer,
        "reasoning_tree": result_tree
    }
```

### Ensemble Retrieval and Consensus Generation

Using multiple retrieval strategies and comparing answers:

```python
def ensemble_rag(query, knowledge_bases, llm):
    # Step 1: Retrieve using multiple strategies/sources
    all_retrieved_docs = []
    
    # Vector search
    vector_docs = knowledge_bases["vector"].retrieve(query, top_k=5)
    all_retrieved_docs.append({"method": "vector", "docs": vector_docs})
    
    # Keyword search
    keyword_docs = knowledge_bases["keyword"].retrieve(query, top_k=5)
    all_retrieved_docs.append({"method": "keyword", "docs": keyword_docs})
    
    # Knowledge graph
    kg_docs = knowledge_bases["kg"].retrieve(query, top_k=5)
    all_retrieved_docs.append({"method": "kg", "docs": kg_docs})
    
    # Step 2: Generate an answer with each set of documents
    candidate_answers = []
    
    for retrieval_result in all_retrieved_docs:
        method = retrieval_result["method"]
        docs = retrieval_result["docs"]
        
        prompt = f"""
        Question: {query}
        
        Please answer based on the following information retrieved using {method}:
        {format_documents(docs)}
        
        Answer:
        """
        
        answer = llm.generate(prompt)
        candidate_answers.append({"method": method, "answer": answer, "docs": docs})
    
    # Step 3: Generate consensus answer
    consensus_prompt = f"""
    Question: {query}
    
    You have multiple candidate answers from different retrieval methods:
    
    {format_candidate_answers(candidate_answers)}
    
    Please analyze these answers and generate a consensus response that:
    1. Incorporates the most reliable information from each answer
    2. Resolves any contradictions by preferring information with stronger evidence
    3. Acknowledges uncertainty where appropriate
    4. Provides a comprehensive response to the original question
    
    Consensus answer:
    """
    
    consensus_answer = llm.generate(consensus_prompt)
    
    return {
        "consensus_answer": consensus_answer,
        "candidate_answers": candidate_answers
    }
```

## Implementation Considerations

- **Computational Cost**: Multi-step processes can increase latency and token usage
- **Error Propagation**: Errors in early steps may cascade through the pipeline
- **Dynamic Control Flow**: Consider using adaptive strategies based on query complexity
- **Observability**: Implement detailed logging to understand the decision process
- **Human Feedback**: Consider adding human feedback loops for critical applications

## Related Patterns

- [Basic RAG Implementation]({{< ref "/docs/retrieval-augmented-generation/basic-rag.md" >}})
- [Advanced Retrieval Strategies]({{< ref "/docs/retrieval-augmented-generation/advanced-retrieval.md" >}})
- [RAG with Document Chunking]({{< ref "/docs/retrieval-augmented-generation/document-chunking.md" >}})