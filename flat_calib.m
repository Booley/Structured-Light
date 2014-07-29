% have double checked all provided values.
fLength_cam = 1810.1474416363599;
r1_cam = [0.73806722247669554,-0.028323229924884147,-0.67413245712705339];
r2_cam = [0.1132176273016446,-0.97975380410093449,0.16511890327256307];
r3_cam = [-0.66516054000047409,-0.19819252759973138,-0.7199174800141388];
t_cam = [94.642517476195309,27.032550702160066,103.8871837100176];

cx_cam = 262.91908840633334;
cy_cam = 264.91512290363539;
sx_cam = 0.99575226683632867;
kappa1_cam = -1.8508655235338357e-008;


r1_proj = [0.73335267749288013,-0.0020289534727800096,-0.67984537489184182];
r2_proj = [0.087273761382215376,-0.99144065949848148,0.09710154101463063];
r3_proj = [-0.67422336134861405,-0.13054233811687746,-0.72689858781727934];
t_proj = [95.475385712589187,-2.6289359800923897,105.65348155760124];

cx_proj = 0.5108035872031238;
cy_proj = 1.1065735011470048;
fy_proj = 3.2023164118108385; % appears just as f
sx_proj = 0.56619562620870267;

% everything below is derived
fx_cam = fLength_cam * sx_cam;
fy_cam = fLength_cam;
distortion_cam = [kappa1_cam,0,0,0,0];

fc = [fx_cam;fy_cam];
cc = [cx_cam;cy_cam];
alpha = sx_cam;
kc = distortion_cam;



% calculate translation and rotation matrices. all needs to be checked
r_cam = [r1_cam', r2_cam', r3_cam'];
r_proj = [r1_proj', r2_proj', r3_proj'];

% should double check these. Conflicting sources
R = r_cam * r_proj'; % brings right to left
T = t_cam' - R * t_proj';



