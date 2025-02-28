---
weight: 1
title: "Basic RAG Implementation"
---

# Basic RAG Implementation

This pattern describes a straightforward implementation of Retrieval Augmented Generation (RAG) that serves as a foundation for more advanced patterns.

## Pattern Description

Basic RAG combines vector search with language model generation to provide more accurate, up-to-date, and verifiable responses. This pattern focuses on the core components and flow of a RAG system.

## Architecture Components

### 1. Document Processing Pipeline

- **Document Loading**: Ingest documents from various sources (PDF, HTML, Markdown, etc.)
- **Text Chunking**: Split documents into manageable chunks
- **Embedding Generation**: Convert text chunks to vector embeddings
- **Vector Storage**: Store embeddings in a vector database with metadata

### 2. Query Pipeline

- **Query Embedding**: Convert user query to vector representation
- **Semantic Search**: Find relevant chunks using vector similarity
- **Prompt Construction**: Create a prompt that includes retrieved information
- **LLM Generation**: Generate a response based on the augmented prompt

## Implementation Example

Here's a simplified Python implementation using LangChain:

```python
from langchain.document_loaders import DirectoryLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.chat_models import ChatOpenAI
from langchain.chains import RetrievalQA

# 1. Load documents
loader = DirectoryLoader('./documents/', glob="**/*.pdf")
documents = loader.load()

# 2. Split into chunks
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=100
)
chunks = text_splitter.split_documents(documents)

# 3. Create embeddings and vector store
embeddings = OpenAIEmbeddings()
vector_store = Chroma.from_documents(chunks, embeddings)

# 4. Create a retrieval chain
llm = ChatOpenAI(model="gpt-4")
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",  # Simple approach that stuffs all context into one prompt
    retriever=vector_store.as_retriever()
)

# 5. Query the system
response = qa_chain.run("What are the key benefits of RAG systems?")
print(response)
```

## Prompt Engineering for RAG

The prompt template is crucial for effective RAG. Here's an example:

```
You are an assistant that answers questions based on the provided context information.

CONTEXT:
{retrieved_documents}

QUESTION:
{user_query}

Give a comprehensive answer based ONLY on the information provided in the CONTEXT.
If the context doesn't contain relevant information, say "I don't have enough information to answer this question."
Always cite the source of your information from the context.
```

## Performance Considerations

- **Chunk Size**: Finding the right chunk size is critical (typically 500-1500 tokens)
- **Embedding Quality**: Higher-dimensional embeddings generally provide better retrieval
- **Number of Retrieved Chunks**: Balance between comprehensive information and context limits
- **Filtering**: Use metadata filtering to narrow down the search space

## Common Challenges

1. **Relevance vs. Diversity**: Retrieving similar chunks may provide redundant information
2. **Context Length Limitations**: Too many retrieved documents may exceed context windows
3. **Query-Document Mismatch**: User query phrasing may not match document terminology
4. **Single-hop Limitations**: Basic RAG struggles with multi-step reasoning

## Related Patterns

<!-- TODO: Add files or update references when content is available -->
<!-- - [Advanced Retrieval Strategies]({{< ref "/docs/retrieval-augmented-generation/advanced-retrieval.md" >}}) -->
<!-- - [RAG with Document Chunking]({{< ref "/docs/retrieval-augmented-generation/document-chunking.md" >}}) -->
<!-- - [Multi-step RAG]({{< ref "/docs/retrieval-augmented-generation/multi-step-rag.md" >}}) -->