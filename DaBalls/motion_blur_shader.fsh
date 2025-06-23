void main()
{
    vec4 current_color = texture2D(u_texture, v_tex_coord);
    
    vec4 previous_color = texture2D(prevframe, v_tex_coord);
    
    float persistence = 0.5;

    if (current_color.a > 0.0) {
        gl_FragColor = mix(current_color, previous_color, persistence);
    } else {
        gl_FragColor = previous_color * persistence;
    }
}
