<?php

apc_clear_cache();
apc_clear_cache('user');
apc_clear_cache('opcode');
header('HTTP/1.0 200 Ok');
print "APC Cache clear successfully...";
