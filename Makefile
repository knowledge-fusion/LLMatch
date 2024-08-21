format:
	git add .
	pipenv run pre-commit run --all-files
	git commit -am "automated format code"
	git push



deploy-lab:
	rsync -avzP -e "ssh -p 2226" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' . wangsha@kg.aws:ontology-alignment
	rsync -avzP -e "ssh -p 2224" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' . wangsha@kg.aws:ontology-alignment

download-lab:
	rsync -avzP -e "ssh -p 2224" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' wangsha@kg.aws:ontology-alignment/ontology-alignment/llm_ontology_alignment/ .llm_ontology_alignment/

run:
	pipenv run python main.py

run-coma:
	java -Xmx1024m -cp .venv/lib/python3.11/site-packages/valentine/algorithms/coma/artifact/coma.jar -DinputFile1=dataset/CIDXPOSCHEMA.xdr -DinputFile2=dataset/Paragon.xdr -DoutputFile=/Users/aloha/Downloads/Sources/PO/Paragon.xdr -DmaxN=0 -Dstrategy=COMA_OPT Main