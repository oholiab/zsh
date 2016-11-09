GIT_CMP_VERS=v2.9.2

OS=$(shell uname)
ifeq ($(OS),Darwin)
	SHACMD = shasum -a 256 
else
	SHACMD = sha256sum
endif

default: all

all: completions/_git ../.zshrc

tmp completions: 
	mkdir $@

completions/%: NAME=$(shell basename $@)
completions/_git: tmp completions completions/git-completion.bash
	curl -o tmp/$(NAME) https://raw.githubusercontent.com/git/git/$(GIT_CMP_VERS)/contrib/completion/git-completion.zsh
	[ "$$($(SHACMD) tmp/$(NAME))" = "9e9acc58e20f8e2e4fcb5b264a50e5acfec22dcf9fe24da65d2ea6234c815e01  tmp/$(NAME)" ]
	mv tmp/$(NAME) ./completions/

completions/git-completion.bash: tmp completions
	curl -o tmp/$(NAME) https://raw.githubusercontent.com/git/git/$(GIT_CMP_VERS)/contrib/completion/git-completion.bash
	[ "$$($(SHACMD) tmp/$(NAME))" = "535a1dc6ad4fd69833982cee8d010f5a0fec955f6b12195e95c68c95e38a027c  tmp/$(NAME)" ]
	mv tmp/$(NAME) ./completions/

../.zshrc:
	cd ../ && ln -s .zsh/.zshrc
