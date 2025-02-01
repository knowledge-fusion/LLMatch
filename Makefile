format:
	git add .
	pipenv run pre-commit run --all-files
	git commit -am "automated format code"
	git push

run:
	pipenv run python main.py

install:
	pipenv install --dev

deploy-mbp:
	rsync -avzP -rt --delete  --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' --exclude ".venv" --exclude "data" . mac.intel:Projects/ontology-alignment
