%% Generalized-Total-Least-Squares
% berechnet die Parameter eines Modells. Die Daten sind teilweise
% verrauscht (Xn). Neben den rauschfreien Daten (W0) muss eine
% Gewichtungsmatrix (Q), sowie eine Aussage uebergeben werden, ob der 
% Ausgang y verrauscht ist (yNoisy).
% Der Parametervektor Theta bezieht sich auf die Regressormatrix 
% W = [Wn Wo].  Es wird vorrausgesetzt, dass y in der ersten Spalte des
% zugehoerigen Regressors steht.
% Der Offset des Modells wird generell immer berechnet und ist in der
% Varaiblen 'bias' zu finden.
function [Theta,bias] = WGTLSEstimate(Wn, Wo, q, yNoisy)
%% Initialisierung
% 'Theta' wird mit einsen gefuellt
Theta = ones(size(Wn,2)+size(Wo,2)-1,1);
% Vektor mit Einsen 
Eins = ones(size(Wn,1),1);
% Transformation des Gewichtungsvektors in eine Matrix
Q=diag(sparse(q));
% Summe der Gewichte 
sq=sum(q);

%% Berechnung der Ersatzregressoren 'WoTilde' und 'WnTilde'
if ~isempty(Wo)
    % Wenn 'Wo' nicht leer ist, wird ein Vektor 'woBar' erstellt.
    % 'woBar' zeigt in den gewichteten Schwerpunkt. Hierbei wird jede
    % Spalte mit dem zugehoerigen Gewicht in q multipliziert und
    % aufaddiert. Die Laenge des Vektors wird durch die Summe der Gewichte
    % angepasst.
    woBar = 1/sq*Wo'*q;
    % Der Schwerpunktsvektor bezieht die Matrix 'Wo' auf den Ursprung. 
    WoTilde=Wo-Eins*woBar';
else
    % Wenn 'Wo' leer ist, werden die Daten 'woBar' und 'WoTilde' zu Null
    % gesetzt.
    woBar=0/sq*Wn'*q;
    WoTilde=Wn*0;
end

% Wie bei den rauschfreien Daten werden auch die verrauschten Daten auf den
% Ursprung bezogen. Mit Schwerpunktsvektor 'myn' und Ersatzregressor
% 'WnTilde'.
myn = 1/sq*Wn'*q;
WnTilde = Wn-Eins*myn';


if ~isempty(Wo)
    % Bei vorhandenen rauschfreien Daten, werden die Parameter bestimmt,
    % welche die rauschfreien Daten auf die verrauschten Daten abbilden. 
    C = pinv(WoTilde'*Q*WoTilde)*WoTilde'*Q*WnTilde;
else
    % Sind alle Daten verrauscht ("TLS-Fall") wird der Parameter auf Null
    % gesetzt
    C=0;
end


%% Minimum des quadratischen Fehlers / Eigenwerte und Eigenvektoren
% Die Verlustfunktion enthaelt zwei Terme. Durch die folgende Wahl wird
% einer der beiden Terme zu Null gesetzt, sodass nur der zweite Term
% analytisch miniert wird.
m=myn-C'*woBar;

[bTilde, bTildeValues] = eig((WnTilde - WoTilde*C)'*Q*(WnTilde - WoTilde*C));
[~, minIndex] = min(diag(bTildeValues));
bTilde = bTilde(:,minIndex);
b=bTilde/norm(bTilde);

% Die zwei Faelle von yNoisy
jj=0;
if yNoisy
    for ii = 2:size(Wn,2)+size(Wo,2)
        if ii <= size(Wn,2)
            Theta(ii-1) = -b(ii)/b(1);
        else
            jj=jj+1;
            Theta(ii-1) = C(jj,:)*b/b(1);
        end
    end
    bias=m'*b/b(1);
else
    jj=1;
    for ii = 1:size(Wn,2)+size(Wo,2)-1
        if ii <= size(Wn,2)
            Theta(ii) = -b(ii)/(C(1,:)*b);
        else
            jj=jj+1;
            Theta(ii) = -C(jj,:)*b/(C(1,:)*b);
        end
    end
    bias=-m'*b/(C(1,:)*b);
end
end