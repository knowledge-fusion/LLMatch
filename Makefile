format:
	pipenv run pre-commit run --all-files

deploy-lab:
	rsync -avzP -e "ssh -p 2224" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' . wangsha@kg.aws:ontology-alignment

run:
	pipenv run python main.py