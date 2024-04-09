void main()
{
    vec4 prev = texture2D(prevframe, v_tex_coord);
    gl_FragColor = texture2D(u_texture, v_tex_coord) + prev * 0.5;
}
