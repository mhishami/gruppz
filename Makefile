PROJECT = gruppz
DEPS = tuah eunit_formatters erlmarkdown
dep_tuah = git https://github.com/mhishami/tuah.git master
dep_erlmarkdown = git https://github.com/erlware/erlmarkdown.git master

include erlang.mk
