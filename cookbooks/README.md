# Cookbooks for Step 3.5 Flash

Welcome to the Step 3.5 Flash Cookbooks! This directory contains a collection of practical examples, recipes, and guides to help you get the most out of the Step 3.5 Flash reasoning model.

## 📚 What is a Cookbook?

A cookbook is a self-contained project, integration guide, or example that demonstrates how to solve a specific problem or implement a feature using Step 3.5 Flash. 

Whether it's a simple API integration, a guide on connecting with frameworks like LangChain/LlamaIndex, a complex reasoning agent, or a data processing pipeline, cookbooks are designed to be hands-on and easy to follow. We encourage you to add **Integration Guides** here as well, as they serve as excellent "recipes" for developers connecting Step 3.5 Flash with their existing tools.

## 🚀 How to Add a Cookbook

We welcome contributions! If you've built something cool with Step 3.5 Flash, please share it with the community.

1.  **Create a New Directory**: Inside the `cookbooks` folder, create a new directory named after your topic. Use `kebab-case` (e.g., `advanced-reasoning-agent`, `rag-implementation`).
2.  **Add Your Code**: Include all necessary source code. Python scripts (`.py`) or Jupyter Notebooks (`.ipynb`) are preferred.
3.  **Add Dependencies**: Create a `requirements.txt` file listing all the Python libraries required to run your code.
4.  **Write Documentation**: Create a `README.md` inside your directory explaining what the cookbook does and how to run it.
5.  **Submit a Pull Request**: Push your changes to a branch and open a PR against the main repository.

## � Call for Contributions

We deeply value our community's creativity! If your cookbook is accepted and merged, we'd love to send you a small gift as a token of our appreciation.

*   **Contact Us**: Please email us at [developer@stepfun.com](mailto:developer@stepfun.com).
*   **Include**: A link to your merged PR and your mailing address so we can ship your gift!

## �🏗 Basic Structure for a Cookbook

To ensure consistency, please follow this standard directory structure:

```text
cookbooks/
└── your-cookbook-name/
    ├── README.md           # Documentation for your specific cookbook
    ├── requirements.txt    # Python dependencies
    ├── main.py             # Main entry point (or .ipynb)
    └── data/               # (Optional) Sample data needed for the example
```

### Content of `README.md` (for your cookbook)

Your cookbook's README should ideally include:
*   **Title**: Clear and descriptive.
*   **Description**: What problem does this solve?
*   **Prerequisites**: API keys, specific OS, etc.
*   **Installation**: `pip install -r requirements.txt`
*   **Usage**: Command to run the example.
*   **Example Output**: What users should expect to see.

## 🤖 AI Tools for Documentation Refinement

To ensure high-quality documentation, we recommend using AI tools to refine your writing before submitting. Here are some prompts you can use to polish your `README.md` and comments.

### Prompt 1: Structure and Clarity
> "I have written a draft README for a code example. Please review it for structure and clarity. Ensure it has a clear Introduction, Prerequisites, Installation steps, and Usage guide. Suggest improvements to make it more professional and easy to follow for developers."

### Prompt 2: Tone and Word Usage
> "Reword the following technical documentation to be more concise and professional. Use active voice where possible. Ensure the tone is helpful and encouraging but technically precise. [Insert your text here]"

### Prompt 3: Code Explanation
> "Here is a Python function from my project. Please generate a clear, step-by-step explanation of how it works, suitable for inclusion in a tutorial or specific documentation. [Insert code here]"
