format:
	git add .
	pipenv run pre-commit run --all-files
	git commit -am "automated format code"
	git push

run:
	pipenv run python main.py

install:
	pipenv install --dev