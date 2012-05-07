-- Copyright (C) 2007 Lauri Leukkunen <lle@rahina.org>
-- Copyright (C) 2012 Nokia Corporation.
-- Licensed under MIT license.

-- Rule file interface version, mandatory.
--
fs_rule_lib_interface_version = "105"
----------------------------------

-- /dev rules.

rules_dev = {
	-- FIXME: This rule should have "protection = eaccess_if_not_owner_or_root",
	-- but that kind of protection is not yet supported.

	-- ==== Blacklisted targets: ====
	-- Some real device nodes (and other objects in /dev)
	-- should never be accessible from the scratchbox'ed session.
	-- Redirect to a session-specific directory.
	{path = "/dev/initctl",
	 map_to = session_dir, protection = readonly_fs_if_not_root },
	-- ==== End of Blacklist ====

	-- We can't change times or attributes of host's devices,
	-- but must pretend to be able to do so. Redirect the path
	-- to an existing, dummy location.
	{dir = "/dev",
	 func_class = FUNC_CLASS_SET_TIMES,
	 set_path = session_dir.."/dummy_file", protection = readonly_fs_if_not_root },

	-- The directory itself.
	{path = "/dev", use_orig_path = true},

	-- If a selected device node needs to be opened with
	-- O_CREAT set, use the real device (e.g. "echo >/dev/null"
	-- does that)
	{path = "/dev/console",
	 func_class = FUNC_CLASS_CREAT, use_orig_path = true},
	{path = "/dev/null", 
	 func_class = FUNC_CLASS_CREAT, use_orig_path = true},
	{prefix = "/dev/tty", 
	 func_class = FUNC_CLASS_CREAT, use_orig_path = true},
	{prefix = "/dev/fb", 
	 func_class = FUNC_CLASS_CREAT, use_orig_path = true},

	-- mknod is simulated. Redirect to a directory where
	-- mknod can create the node.
	-- Also, typically, rename() is used to rename nodes created by
	-- mknod() (and it can't be used to rename real devices anyway).
	-- It must be possible to create symlinks and files in /dev, too.
	{dir = "/dev",
	 func_class = FUNC_CLASS_MKNOD + FUNC_CLASS_RENAME +
		      FUNC_CLASS_SYMLINK + FUNC_CLASS_CREAT,
	 map_to = session_dir, protection = readonly_fs_if_not_root },

	-- Allow removal of simulated nodes, regardless of the name
	-- (e.g. a simulated /dev/null might have been created 
	-- to session_dir, even if it won't be used due to the 
	-- /dev/null rule below)
	{dir = "/dev",
	 func_class = FUNC_CLASS_REMOVE,
	 actions = {
		{ if_exists_then_map_to = session_dir },
		{ use_orig_path = true }
	 },
	},

	-- Default: If a node has been created by mknod, and that was
	-- simulated, use the simulated target.
	-- Otherwise use real devices.
	-- However, there are some devices we never want to simulate...
	{path = "/dev/console", use_orig_path = true},
	{path = "/dev/null", use_orig_path = true},
	{prefix = "/dev/tty", use_orig_path = true},
	{prefix = "/dev/fb", use_orig_path = true},
	{dir = "/dev", actions = {
			{ if_exists_then_map_to = session_dir },
			{ use_orig_path = true }
		},
	},
}

return rules_dev

