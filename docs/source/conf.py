# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'linux-server-assignment'
copyright = '2026, Sou Chanrojame'
author = 'Sou Chanrojame, Orn Pheakdey, Long Neron, Le Sreyma, Then Sivthean'

# Fudge the latex author list, insert \and where you want the line break to appear
max_characters_author_line = 50
if len(author) > max_characters_author_line:
    author_list = [author.strip() for author in author.split(',')]
    i = len(author_list)
    for i in range(1, len(author_list)):
        if len(", ".join(author_list[:i])) > max_characters_author_line:
            i = i-1
            break
    latex_author = ", ".join(author_list[:i]) + ", \\and " + ", ".join(author_list[i:])
else:
    latex_author = author

latex_elements = {
    "maketitle": "\\author{" + latex_author + "}\\sphinxmaketitle"
}

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = []

latex_engine = "xelatex"

templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static']
