---
title: "Template-Based Prompt Systems"
weight: 40
---

# Template-Based Prompt Systems

Prompt templates provide structured frameworks for generating consistent, reusable prompts across different use cases and applications.

## Why Use Prompt Templates

- **Consistency**: Ensure all prompts follow best practices
- **Reusability**: Create prompts once, use them repeatedly with different inputs
- **Modularity**: Compose complex prompts from simple building blocks
- **Maintenance**: Update prompts in a single location
- **Version Control**: Track changes to prompts over time

## Basic Structure

A template system typically includes:

1. **Variables**: Placeholders for dynamic content
2. **Static Text**: Consistent instructions and formatting
3. **Conditionals**: Optional sections based on context
4. **Metadata**: Information about the template purpose and usage

## Implementation Patterns

### Simple Variable Substitution

```
You are a helpful assistant providing information about {topic}.
The user is a {audience_type} with {expertise_level} knowledge level.
Please provide a {length} explanation about: {query}
```

### Component-Based Templates

Break prompts into reusable sections:

```python
def create_prompt(components, variables):
    prompt_parts = []
    
    if "role" in components:
        prompt_parts.append(ROLE_TEMPLATES[components["role"]].format(**variables))
    
    if "task" in components:
        prompt_parts.append(TASK_TEMPLATES[components["task"]].format(**variables))
    
    if "format" in components:
        prompt_parts.append(FORMAT_TEMPLATES[components["format"]].format(**variables))
    
    return "\n\n".join(prompt_parts)
```

### Template Libraries

Create collections of tested, optimized templates for specific scenarios:

- Classification templates
- Summarization templates
- Creative writing templates
- Analysis templates

## Advanced Template Techniques

### Context-Aware Templates

```python
def generate_prompt(user_query, context):
    # Select template based on query characteristics
    if contains_technical_terms(user_query):
        base_template = TECHNICAL_TEMPLATE
    elif is_creative_request(user_query):
        base_template = CREATIVE_TEMPLATE
    else:
        base_template = GENERAL_TEMPLATE
    
    # Add context-specific elements
    if context.get("user_history"):
        base_template += USER_HISTORY_TEMPLATE
    
    return base_template.format(query=user_query, **context)
```

### Dynamic Template Selection

Use AI to select or compose templates:

```
Given the following user query: "{query}"
Select the most appropriate prompt template from the following options:
1. {template_1_description}
2. {template_2_description}
3. {template_3_description}

Explain your reasoning, then output the chosen template number.
```

## Template Management

- **Testing**: Evaluate template performance with different inputs
- **Versioning**: Track template changes over time
- **Documentation**: Document purpose, variables, and usage examples
- **Error Handling**: Validate inputs and provide fallbacks

## Code Example: Template Implementation

```python
class PromptTemplate:
    def __init__(self, template_string, required_variables=None):
        self.template = template_string
        self.required_variables = required_variables or []
    
    def format(self, **kwargs):
        # Validate all required variables are present
        missing = [var for var in self.required_variables if var not in kwargs]
        if missing:
            raise ValueError(f"Missing required variables: {', '.join(missing)}")
        
        # Apply the variables to the template
        return self.template.format(**kwargs)

# Example usage
summary_template = PromptTemplate(
    "Summarize the following text in {style} style with {word_count} words:\n\n{text}",
    required_variables=["text", "style", "word_count"]
)

prompt = summary_template.format(
    text="Lorem ipsum...",
    style="concise",
    word_count=100
)
```

## Related Patterns

- [System Prompt Design]({{< ref "/docs/prompt-engineering/system-prompts.md" >}})
- [Role-Based Prompting]({{< ref "/docs/prompt-engineering/role-prompting.md" >}})