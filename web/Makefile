WML_FILES = $(wildcard *.wml)
HTML_FILES = $(subst .wml,.html,$(WML_FILES))
HTML_DEPS= $(wildcard template/*.wml)

wml: $(HTML_FILES)

WML = wml
WML_FLAGS = -I"template" -n

%.html: %.wml $(HTML_DEPS)
	$(WML) $(WML_FLAGS) -DWMLFILE=$< -o $@ $<

