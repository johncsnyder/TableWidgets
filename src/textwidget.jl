


type TextWidget
    content::AbstractString
end



get_comm(w::TextWidget) = Comm(symbol("widget",object_id(w)))


function Base.writemime(io, ::MIME"text/html", w::TextWidget)
    id = object_id(w)
    content = w.content
    html = """
    <script>
        var comm_manager = IPython.notebook.kernel.comm_manager;
        comm_manager.register_target(
            "widget$id",
            function (comm) {
                comm.on_msg(function (msg) {
                    var content = msg.content.data["content"];
                    var elems = document.getElementsByClassName("widget$id");
                    for (i = 0; i < elems.length; i++) { elems[i].innerHTML = content };
                });
            }
        );
    </script>
    <pre class="widget$id">$content</pre>
    """
    write(io, html)
end




function update(w::TextWidget, content::AbstractString)
    comm = get_comm(w)
    w.content = content
    msg = Dict("content" => content)
    send_comm(comm, msg)
end




