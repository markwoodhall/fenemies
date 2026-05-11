LUA_DIR=lua
LUA=lua/src/lua
SRC=main.fnl args.fnl display.fnl log.fnl rules.fnl robots.fnl iis.fnl report.fnl probes.fnl

fenemies: $(SRC) $(LUA) $(LUA_DIR)/src/liblua.a
	@echo "Building.."
	./fennel --compile-binary $< $@ $(LUA_DIR)/src/liblua.a $(LUA_DIR)/src
	chmod 755 $@
	strip $@

$(LUA): $(LUA_DIR) ; make -C $^

clean:
	@echo "Cleaning.."
	rm -rf fenemies
	make -C lua clean

repl: $(LUA)
	@echo "Launching repl"
	./fennel

.PHONY: clean install repl
