
let time_splitter = Str.regexp "\\(^[0-9]+:[0-9]+\\)\ \\(.+\\)"

let () = 
    let open Yojson.Basic.Util in
    Yojson.Basic.from_file "sample.info.json"
    |> member "description" 
    |> to_string
    |> Str.split (Str.regexp "\n")
    |> List.filter (fun s -> 
            Str.string_match time_splitter s 0)
    |> List.map (fun s ->
            Str.string_match time_splitter s 0 |> ignore;
            (Str.matched_group 1 s, Str.matched_group 2 s))
    |> List.iter (fun (a,b) -> Printf.printf "time: %s, track: %s\n" a b)


    
