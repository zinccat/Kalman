dt = 0.1;

A = [1 dt
     0 1];

B = [0.5 * dt^2
     dt];

C = [1 0];

D = 0;

Ts = -1; % Discrete
sys = ss(A,[B B],C,D,Ts,'InputName',{'u' 'w'},'OutputName','y');  % Plant dynamics and additive input noise w

Q = 5; 
R = 2; 

[kalmf,L,~,Mx,Z] = kalman(sys,Q,R);

kalmf = kalmf(1,:);


sys.InputName = {'u','w'};
sys.OutputName = {'yt'};
vIn = sumblk('y=yt+v');

kalmf.InputName = {'u','y'};
kalmf.OutputName = 'ye';

SimModel = connect(sys,vIn,kalmf,{'u','w','v'},{'yt','ye'});

t = (0:1000)';
% u = ones(size(t));
u = sin(0.1*t);

rng(10,'twister');
w = sqrt(Q)*randn(length(t),1);
v = sqrt(R)*randn(length(t),1);

out = lsim(SimModel,[u,w,v]);

yt = out(:,1);   % true response
ye = out(:,2);  % filtered response
y = yt + v;     % measured response

clf

subplot(211), plot(t,yt,'b',t,ye,'r--'), 
xlabel('Number of Samples'), ylabel('Output')
title('Kalman Filter Response')
legend('True','Filtered')
subplot(212), plot(t,yt-y,'g',t,yt-ye,'r--'),
xlabel('Number of Samples'), ylabel('Error')
legend('True - measured','True - filtered')

norm(yt-y)

norm(yt-ye)

(norm(yt-y) - norm(yt-ye))/norm(yt-y)


