ELM=@elm-make
CLOSURE=@closure-compiler
CLOSURE_FLAGS=--compilation_level SIMPLE_OPTIMIZATIONS \
			  --warning_level QUIET 				   \
			  --language_in ECMASCRIPT5 			   \
			  --jscomp_off globalThis

ELM_SRC=src
PUBLIC=public
STATIC_JS=$(PUBLIC)/static/js

.PHONY: clean reset

default: elm

elm: $(STATIC_JS)/elm.min.js

$(STATIC_JS)/elm.min.js: $(ELM_SRC)/elm.js
	@echo "Compressing elm.js with closure"
	$(CLOSURE) $(CLOSURE_FLAGS) --js $(ELM_SRC)/elm.js --js_output_file $(STATIC_JS)/elm.min.js
	@sed 's#elm.js#static/js/elm.min.js#' $(ELM_SRC)/index.html > $(PUBLIC)/index.html

$(ELM_SRC)/elm.js: $(ELM_SRC)/Main.elm
	@echo "Building elm.js"
	$(ELM) --output $(ELM_SRC)/elm.js $(ELM_SRC)/Main.elm

test: $(ELM_SRC)/elm.js
	@echo "Running Tests"
	@elm-test

clean:
	@echo "cleaning up"
	@rm $(ELM_SRC)/elm.js
	@rm $(PUBLIC)/index.html
	@rm $(STATIC_JS)/elm.min.js

reset: clean
	@echo "reseting"
	@rm -rf elm-stuff
