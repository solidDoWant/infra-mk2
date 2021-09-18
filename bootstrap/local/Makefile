VENV_PATH=$(realpath .)/../../working/venv

ANSIBLE_INVENTORY=$(realpath . )/../remote/inventory
ANSIBLE_PLAYBOOK=$(realpath . )/../remote/ansible.yaml

build_venv:
	apt install python3-venv -y
	python3 -m venv $(VENV_PATH)
	( \
		. $(VENV_PATH)/bin/activate; \
		pip install -U pip; \
		pip install ansible; \
		pip install -r requirements.txt; \
	)

run_playbook: build_venv
	( \
		. $(VENV_PATH)/bin/activate; \
		ansible-playbook -i $(ANSIBLE_INVENTORY) $(ANSIBLE_PLAYBOOK); \
	)
