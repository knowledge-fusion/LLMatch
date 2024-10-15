format:
	git add .
	pipenv run pre-commit run --all-files
	git commit -am "automated format code"
	git push

deploy-mbp:
	rsync -avzP -rt --delete  --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' --exclude ".venv" --exclude "data" . mac.intel:Projects/ontology-alignment


deploy-lab: deploy-mbp
	rsync -avzP -e "ssh -p 2226" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' . wangsha@kg.aws:ontology-alignment
	rsync -avzP -e "ssh -p 2224" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' . wangsha@kg.aws:ontology-alignment

download-lab:
	rsync -avzP -e "ssh -p 2224" -rt --delete --exclude '.venv' --exclude '.*' --exclude '*.pyc'  --exclude '*.zip' wangsha@kg.aws:ontology-alignment/llm_ontology_alignment/ llm_ontology_alignment/

run:
	pipenv run python main.py

#docker run -it --rm -p 11434:8080 --gpus=all -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:ollama

#docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=http://mac-dev-server-1.detalytics.com:8001 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
run-coma:
	java -Xmx1024m -cp .venv/lib/python3.11/site-packages/valentine/algorithms/coma/artifact/coma.jar -DinputFile1=dataset/CIDXPOSCHEMA.xdr -DinputFile2=dataset/Paragon.xdr -DoutputFile=/Users/aloha/Downloads/Sources/PO/Paragon.xdr -DmaxN=0 -Dstrategy=COMA_OPT Main