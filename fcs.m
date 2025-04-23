R = 3;
M = 3;
A = zeros(R*2);

I = eye(3);
A_rightbot = I(:, [2 3 1]);

A_leftbot = zeros(R);
A_leftbot(1,1) = 1;

A_lefttop = zeros(3);
E = eye(2);
A_lefttop(1:2, 2:3) = E;

% x^3 + x^2 + 1
g = [1 1 0 1]
gg = flip(g)
A_lefttop(3,:) = gg(1:3)

A(1:3, 1:3) = A_lefttop;
A(4:6, 1:3) = A_leftbot;
A(4:6, 4:6) = A_rightbot;

A


%%

R = 32;
M = 8;
X = 32+8
A = zeros(X);

%højre bund skal være en 8x8 matrix
I = eye(M);
A_rightbot = I(:, [2:end, 1]);

%venstre bund 8x32 matrix
A_leftbot = zeros(M,R);
A_leftbot(1,1) = 1;

%venstre top 32x32 matrix
A_lefttop = zeros(R);
E = eye(R-1);
A_lefttop(1:end-1, 2:end) = E;

% G(x) = x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
G = [0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 0 0 0 1 0 1 1 1 0 1 1 1];
gg = flip(G)
A_lefttop(R,:) = gg;

%michael okay venstre skal være 11101
%og den skal være på plads nr 32, det ikke 20x20 matrix det det 32 rows og
%så 8 data rows

A(1:R, 1:R) = A_lefttop;
A(R+1:end, 1:R) = A_leftbot;
A(R+1:end, R+1:end) = A_rightbot;

A8 = A^8;
%A = mod(A,2)

%okay det skal se sådan der ud
%r0 xor r3 xor r xor m7


fileID = fopen('VHDL_FCS.txt','w');
for cols = 1:40
    s = "" + sprintf('r(%d) <= ',cols-1);
    for rowsR = 1:R
        if(A8(rowsR,cols) == 1)
        s = s + sprintf(' r(%d) xor', rowsR-1);
        end
    end
    for rowsM = R+1:40
        if(A8(rowsM,cols) == 1)
        s = s + sprintf(' m(%d) xor', rowsM-33);
        end
    end
    s = s + ";\n";
    fprintf(fileID,s);
end
fclose(fileID);


%%

fileID = fopen('VHDL_FCS.txt','w');
for cols = 1:40
    s = sprintf('r(%d) <= ', cols-1);
    terms = [];
    
    for rowsR = 1:R
        if A8(rowsR, cols) == 1
            terms = [terms, sprintf('r(%d)', rowsR-1)];
        end
    end
    
    for rowsM = R+1:40
        if A8(rowsM, cols) == 1
            terms = [terms, sprintf('m(%d)', rowsM-33)];
        end
    end
    
    if ~isempty(terms)
        s = [s, strjoin(terms, ' xor ')];
    end
    
    s = [s, ';
'];
    fprintf(fileID, '%s', s);
end
fclose(fileID);