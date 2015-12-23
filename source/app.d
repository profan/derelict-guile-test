import std.stdio;

import derelict.guile;
import derelict.util.exception;

extern(C)
void inner_main(void* data, int argc, char **argv) {

	scm_shell(argc, argv);

}

ShouldThrow missingSymFunc( string symName ) {

	import std.stdio : writefln;

	if (symName == "scm_c_call_with_blocked_asyncs" ||
		symName == "scm_c_call_with_unblocked_asyncs" ||
		symName == "scm_dynwind_block_asyncs" ||
		symName == "scm_dynwind_unblock_asyncs") {
		writefln("skipped symbol: %s not there in unpatched version.", symName);
		return ShouldThrow.No;
	}

	if (symName == "scm_wait_condition_variable") {
		writefln("no pthreads? : %s", symName);
		return ShouldThrow.No;
	}

    // Any other missing symbol should throw.
    return ShouldThrow.Yes;

}


void main() {

	import core.stdc.stdio;

	DerelictGuile.missingSymbolCallback = &missingSymFunc;
	DerelictGuile.load();

	scm_init_guile();

	auto endianness = scm_native_endianness();
	auto display_proc = scm_variable_ref (scm_c_lookup("display"));
	auto c_test = scm_to_locale_string(scm_object_to_string(endianness, display_proc));
	printf("endianness: %s \n", c_test);

	scm_boot_guile(0, cast(char**)null, &inner_main, null);

}
