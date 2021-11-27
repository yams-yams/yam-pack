let time_splitter = Str.regexp "\\(^[0-9]+:[0-9]+\\)\ \\(.+\\)" (* Splits time stamp and track name *)

type track = {start_time: string; end_time: string; name: string}

let rec track_list_maker total l =
    match l with
    | [] -> []
    | [(timestamp, name)] -> [{ start_time = timestamp; end_time = total; name}]
    | (start_time, name) :: ( (end_time, _) :: _ as t ) ->
            { start_time; end_time; name } :: track_list_maker total t


let () =
    Sys.argv.(1)
    |> ((^) "yt-dlp -x --audio-format mp3  --write-info-json --write-thumbnail -o output.mp3 ")
    |> Sys.command
    |> ignore;
    let open Yojson.Basic.Util in

    let metadata = Yojson.Basic.from_file "output.mp3.info.json" in
    
    let duration = 
        Unix.open_process_in "ffprobe -i output.mp3 -show_entries format=duration -v quiet -sexagesimal -of csv=\"p=0\""
        |> input_line in
            
    let track_list = metadata
        |> member "description" 
        |> to_string                                (* description in one simple string *)
        |> Str.split (Str.regexp "\n")              (* split into lines *)
        |> List.filter (fun s ->                    (* filters out lines that aren't [time stamp track name] *)
                Str.string_match time_splitter s 0)
        |> List.map (fun s ->                       (* maps to a list of tuples of (time stamp, track name *)                        
                Str.string_match time_splitter s 0 |> ignore;
                (Str.matched_group 1 s, Str.matched_group 2 s))
        |> track_list_maker duration in
    
    List.iter (fun {start_time; end_time; name} -> 
              (Printf.sprintf "ffmpeg -i output.mp3 -acodec mp3 -ss %s -to %s \"%s.mp3\"" start_time end_time name
                    |> Sys.command
                    |> ignore)) track_list

