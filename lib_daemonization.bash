
daemonize_script()
{
    _check_daemonize_script_variables

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

_check_daemonize_script_variables()
{
    if [[ -z "$daemon_script" ]]
    then
        echo "daemonize_script: Script not given in \$daemon_script."
        echo "Exiting."
        exit 1
    elif ! [[ -f "$daemon_script" ]]
    then
        echo "daemonize_script: \$daemon_script is not a file."
        echo "\$daemon_script: $daemon_script"
        echo "Exiting."
        exit 1
    elif ! [[ -x "$daemon_script" ]]
    then
        echo "daemonize_script: \$daemon_script is not executable."
        echo "\$daemon_script: $daemon_script"
        echo "Exiting."
        exit 1
    elif [[ -z "$process_file_path" ]]
    then
        echo "Exiting."
        exit 1
    elif ! [[ -d "$process_file_path" ]]
    then
        mkdir -p "$process_file_path"
        if ! [[ -d "$process_file_path" ]]
        then
            echo "daemonize_scripjt: Could not create directory for \$process_file_path."
            echo "Exiting."
            exit 1
        fi
    elif [[ -z "$process_file_prefix" ]]
    then
        echo "daemonize_script: \$process_file_prefix is not set."
        echo "Exiting."
        exit 1
    elif [[ -n "$log_file_stdout" ]] && ! [[ -f "$log_file_stdout" ]]
    then
        echo "daemonize_script: \$log_file_stdout is not a file."
        echo "log_file_stdout: $log_file_stdout"
        echo "Exiting."
        exit 1
    fi
}

