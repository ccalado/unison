(* Unison file synchronizer: src/system/system_intf.ml *)
(* Copyright 1999-2020, Benjamin C. Pierce

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)

module type Core = sig

type fspath
val mfspath : fspath Umarshal.t
type dir_handle = { readdir : unit -> string; closedir : unit -> unit }

val symlink : string -> fspath -> unit
val readlink : fspath -> string
val chown : fspath -> int -> int -> unit
val chmod : fspath -> int -> unit
val utimes : fspath -> float -> float -> unit
val unlink : fspath -> unit
val rmdir : fspath -> unit
val mkdir : fspath -> Unix.file_perm -> unit
val rename : fspath -> fspath -> unit
val stat : fspath -> Unix.LargeFile.stats
val lstat : fspath -> Unix.LargeFile.stats
val opendir : fspath -> dir_handle
val openfile :
  fspath -> Unix.open_flag list -> Unix.file_perm -> Unix.file_descr

(****)

val open_out_gen : open_flag list -> int -> fspath -> out_channel
val open_in_bin : fspath -> in_channel
val file_exists : fspath -> bool

(****)

(* [clone_path] does not raise exceptions. *)
val clone_path : fspath -> fspath -> bool
(* [clone_file] does not raise exceptions. *)
val clone_file : Unix.file_descr -> Unix.file_descr -> bool
(* [copy_file] updates destination file seek position if and only if
   writing succeeded, returning the number of bytes written. *)
val copy_file : Unix.file_descr -> Unix.file_descr -> int64 -> int -> int

(****)

val hasInodeNumbers : unit -> bool
val hasSymlink : unit -> bool

(* [hasCorrectCTime] is true when [stat] and [lstat] return the status change
 * time. This is commonly broken on Windows, where creation time (completely
 * unrelated to ctime; it is the birthtime) is returned instead. However, it
 * is possible to get the correct status change time on Windows, which is why
 * [hasCorrectCTime] can have a different value on different systems. *)
val hasCorrectCTime : bool

(****)

exception XattrNotSupported

val xattr_list : fspath -> (string * int) list
val xattr_get : fspath -> string -> string
val xattr_set : fspath -> string -> string -> unit
val xattr_remove : fspath -> string -> unit

(* [xattrUpdatesCTime] is true if changes to extended attributes update the
 * file ctime. This means that extended attribute changes can be quickly
 * detected by looking at ctime change. If file ctime is not updated then
 * xattrs have to be scanned every time to detect changes. *)
val xattrUpdatesCTime : bool

(****)

val acl_get_text : fspath -> string
val acl_set_text : fspath -> string -> unit

end

module type Full = sig

include Core with type fspath = string

val extendedPath : string -> fspath

val putenv : string -> string -> unit
val getenv : string -> string
val argv : unit -> string array

val fspathToDebugString : fspath -> string

val open_in_gen : open_flag list -> int -> fspath -> in_channel

val link : fspath -> fspath -> unit
val chdir : fspath -> unit
val getcwd : unit -> fspath

val create_process :
  string -> string array ->
  Unix.file_descr -> Unix.file_descr -> Unix.file_descr -> int
val open_process_in : string -> in_channel
val open_process_args_in : string -> string array -> in_channel
val open_process_out : string -> out_channel
val open_process_full :
  string -> in_channel * out_channel * in_channel
val open_process_args_full :
  string -> string array -> in_channel * out_channel * in_channel
val process_in_pid : in_channel -> int
val process_out_pid : out_channel -> int
val process_full_pid : in_channel * out_channel * in_channel -> int
val close_process_in : in_channel -> Unix.process_status
val close_process_out : out_channel -> Unix.process_status
val close_process_full :
  in_channel * out_channel * in_channel -> Unix.process_status

type terminalStateFunctions =
  { defaultTerminal : unit -> unit; rawTerminal : unit -> unit;
    startReading : unit -> unit; stopReading : unit -> unit }
val terminalStateFunctions : unit -> terminalStateFunctions

val termVtCapable : Unix.file_descr -> bool

val has_stdout : info:string -> bool
val has_stderr : info:string -> bool

end
