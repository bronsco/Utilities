
k = 1;
T = 1;
om__Hz = 0.1:0.1:3;
A = 10;
fin = 2;
dt = 0.001;
te = 10;

s = tf('s');
G = k / (T*s+1);

Tp = 1/fin;
[u,t] = gensig('sin',Tp,te,dt) ;
x0 = 0;
[y,t,x] = lsim(G,A*u,t,x0,'foh');


om__rad = om__Hz*2*pi;
[mag,phase] = bode(G,om__rad);
gain = k ./ sqrt(T^2*om__rad.^2+1);

figure
subplot(2,1,1)
grid on
hold on
plot(om__Hz,gain, 'b')
plot(om__Hz,mag(1,:), 'r--')
subplot(2,1,2)
grid on
hold on
plot(t,y,'b')