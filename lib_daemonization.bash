
daemonize_script()
{

    echo "Daemonizing script:"
    echo "    $daemon_script"

    # Remove --daemon option from arguments to avoid infinite loop when calling
    # the script again
    for arg in "$@"
    do
        [[ "$arg" != "--daemon" ]] && local other_args+=( "$arg" )
    done

    local piping=""
    [[ -f "$log_file_stdout" ]] && piping=">$log_file_stdout 2>&1"

    # Run script as background job
    "$daemon_script" "${other_args[@]}" </dev/null "$piping" &
    local process_id=$!

    # Create file indicating daemon process id
    process_file="$process_file_path/${process_file_prefix}-${process_id}"
    echo "$process_id" > "$process_file"

    # Disown the background job
    disown

    # Continues this script instance
}

