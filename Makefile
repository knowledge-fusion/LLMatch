format:
	pipenv run pre-commit run --all-files
	ssh-add --apple-use-keychain ~/.ssh/id_github_knowledgefusion
	git commit -am "automated format code"
	git push



deploy-lab:
	rsync -avzP -e "ssh -p 2226" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' . wangsha@kg.aws:ontology-alignment

run:
	pipenv run python main.py