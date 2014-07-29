% camera calibration data
% unmatchable?
kappa1 = 1.3099513678230924e-009;
fLength_cam = 1802.5569322205215;
sx_cam = .99760386816621505;

%actual calib data
fx_cam = fLength_cam * sx_cam;
fy_cam = fLength_cam;
cx_cam = 255.92770681130986;
cy_cam = 258.7711465696612;
r1_cam = [0.9966244036434102,0.019602265139226353,0.07972169882678494];
r2_cam = [0.0077567113085882664,-0.98921533216285096,0.1462629824788749];
r3_cam = [0.08172901254812974,-0.14515087948528568,-0.98602818960339877];
t_cam = [-9.835679713075681,20.522365838140086,143.86466197751423]; 
distortion_cam = [kappa1,0,0,0,0];

intrinsic_cam = [fx_cam, 0, cx_cam; 
                 0, fy_cam, cy_cam;
				 0, 0, 1];
extrinsic_cam = [r1_cam', r2_cam', r3_cam', t_cam'];


% projector calibration data
alpha_proj = -0.0160829; % unmatchable? use in intrinsics matrix for distortion
fx_proj = 1.88206;
fy_proj = 3.34363;
cx_proj = 0.417802;
cy_proj = 1.25757;
r1_proj = [0.99887019023609613, 0.037563830463145931,0.029108447204222367];
r2_proj = [0.033819231002507985, -0.99220950999286783, 0.11990224307373148];
r3_proj = [0.033385665668127298, -0.11878235104866891, -0.99235888186041188];
t_proj = [-9.2966764494201239, -9.682944298807838, 149.13370814351458];
distortion_proj = [0.363586, -0.848123, 0.044428, -0.0342421,2.03101];

intrinsic_proj = [fx_proj, 0, cx_proj; 
                 0, fy_proj, cy_proj;
				 0, 0, 1];
extrinsic_proj = [r1_proj', r2_proj', r3_proj', t_proj'];


% calculate translation and rotation matrices. all needs to be checked
r_cam = [r1_cam', r2_cam', r3_cam'];
r_proj = [r1_proj', r2_proj', r3_proj'];

R = r_proj * r_cam'; % brings right to left
T = t_proj' - R * t_cam';

% calculate fundamental matrix
S = [0, -T(3), T(2); % correct by all references
	 T(3), 0, -T(1);
	 -T(2), T(1), 0];
F = inv(intrinsic_proj)' * S*R * inv(intrinsic_cam);

% calculate projection matrices
P1 = intrinsic_cam * [eye(3) zeros(3,1)]; % correct by BB
P2 = intrinsic_proj * [R T];

fc = [fx_cam;fy_cam];
cc = [cx_cam;cy_cam];
alpha = sx_cam;
kc = distortion_cam;


