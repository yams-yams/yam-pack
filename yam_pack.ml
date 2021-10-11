
let time_splitter = Str.regexp "\\(^[0-9]+:[0-9]+\\)\ \\(.+\\)" (* Splits time stamp and track name *)

let () =
    Sys.argv.(1)
    |> ((^) "youtube-dl -x --audio-format mp3  --write-info-json --write-thumbnail -o output.mp3 ")
    |> Sys.command
    |> ignore;
let open Yojson.Basic.Util in
    Yojson.Basic.from_file "output.mp3.info.json"
    |> member "description" 
    |> to_string                                (* description in one simple string *)
    |> Str.split (Str.regexp "\n")              (* split into lines *)
    |> List.filter (fun s ->                    (* filters out lines that aren't [time stamp track name] *)
            Str.string_match time_splitter s 0)
    |> List.map (fun s ->                       (* maps to a list of tuples of (time stamp, track name *)                        
            Str.string_match time_splitter s 0 |> ignore;
            (Str.matched_group 1 s, Str.matched_group 2 s))
    |> List.iter (fun (a,b) -> Printf.printf "time: %s, track: %s\n" a b) (* prints the list of tuples *)


    
