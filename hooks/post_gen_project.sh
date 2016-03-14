#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Ensure newline at EOF
find . ! -path "*/venv/*" -type f -name "*.py" -exec bash -c "tail -n1 {} | read -r _ || echo >> {}" \;

echo "${green}[Finished]${reset}"

echo "==> Setup project dependencies? It will:"
echo "  - Create virtualenv at './{{ cookiecutter.github_repository }}/venv/'."
echo "  - Install development requirements inside virtualenv."
echo "  - Create a postgres database named '{{ cookiecutter.main_module }}'."
echo "  - Run './manage.py migrate'."
echo "  - Initialize git."
echo "  - Create git tag {{ cookiecutter.version }}."
echo -n "Would you like to perform these steps? (y/[n]) "
echo ""

# Inside CI, always assume the answer is yes! :)
if [ $CI ]; then
    yn="yes"
else
    read  yn
fi


if echo "$yn" | grep -iq "^y"; then
    echo "==> Checking system dependencies. You may need to enter your sudo password."

    echo "==> Install pip, if not present."
    if ! hash pip 2>/dev/null; then
        echo "pip not found.... installing it..."
        sudo easy_install pip
    fi

    echo "==> Install fabric, if not present."
    if ! hash fab 2>/dev/null; then
        echo "fab command not found... installing it..."
        sudo pip install fabric
    fi

    echo "==> Initialize git repo and create first commit and tag it with v0.0.0"
    git init
    git add .
    git commit -am "chore(setup): create base django project."
    git tag v{{ cookiecutter.version }}

    echo "==> Setup the project dependencies and database for local development"
    fab init

    echo "==> Bumpversion 0.1.0-dev"
    source venv/bin/activate
    bumpversion --no-tag minor

    OUT=$?
    if [ $OUT -eq 0 ]; then
        echo "============================================"
        echo "          This is what we just did!         "
        echo "============================================"
        echo ""
        echo "* created a base django project code base at"
        echo "  `pwd`"
        echo "* installed project dependencies"
        echo "* initialized a git repo and created the first commit"
        echo -n "* you can now cd into `pwd` and start working after "
        echo "activating virtualenv with 'source venv/bin/activate'."
        echo "============================================"
    else
        echo "============================================"
        echo "          Oops! Something went wrong!!      "
        echo "============================================"
        echo ""
        echo -n "HINT: Make sure you have installed all OS dependencies. "
        echo "Check the logs above, they might give you some clues."
    fi
else
    echo "==> Skipping project setup..."
    echo "==> You can now 'cd {{ cookiecutter.github_repository }}/' and explore the project. "
    echo "    Read 'README.md' inside it for further setup instructions!"
    echo ""
    echo "${green} ============> HAPPY CODING <============ ${reset}"
fi
