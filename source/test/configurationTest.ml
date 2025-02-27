(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open Core
open OUnit2

let test_search_path _ =
  let assert_search_paths ?(search_paths = []) ~source_paths expected =
    let search_paths =
      List.map search_paths ~f:PyrePath.create_absolute
      |> List.map ~f:(fun root -> SearchPath.Root root)
    in
    let source_paths = List.map source_paths ~f:PyrePath.create_absolute in
    let to_search_path root = SearchPath.Root root in
    let search_paths =
      Configuration.Analysis.search_paths
        (Configuration.Analysis.create
           ~search_paths
           ~source_paths:(List.map source_paths ~f:to_search_path)
           ())
      |> List.map ~f:SearchPath.show
    in
    assert_equal ~printer:(List.to_string ~f:ident) expected search_paths
  in
  assert_search_paths ~source_paths:["/a"] ["/a"];
  assert_search_paths ~source_paths:["/a"] ["/a"];
  assert_search_paths
    ~search_paths:["/other"; "/another"]
    ~source_paths:["/a"]
    ["/other"; "/another"; "/a"];
  assert_search_paths
    ~search_paths:["/other"; "/another"]
    ~source_paths:["/a"]
    ["/other"; "/another"; "/a"];
  assert_search_paths
    ~search_paths:["/other"; "/another"]
    ~source_paths:["/a"; "/b"]
    ["/other"; "/another"; "/a"; "/b"];
  ()


let test_extensions _ =
  let assert_extensions ~extensions expected =
    let extensions = List.map ~f:Configuration.Extension.create_extension extensions in
    assert_equal
      ~cmp:(List.equal [%compare.equal: Configuration.Extension.t])
      ~printer:(List.to_string ~f:Configuration.Extension.show)
      expected
      extensions
  in
  assert_extensions
    ~extensions:[".extension"]
    [{ Configuration.Extension.suffix = ".extension"; include_suffix_in_module_qualifier = false }];
  assert_extensions
    ~extensions:[".extension$include_suffix_in_module_qualifier"]
    [{ Configuration.Extension.suffix = ".extension"; include_suffix_in_module_qualifier = true }];
  ()


let () =
  "configuration"
  >::: ["search_path" >:: test_search_path; "extensions" >:: test_extensions]
  |> Test.run
