tic();
//OrigImage = imread("lena_256light.jpg");
OrigImage = [[3,3,1],[1,5,2],[2,0,1]];
//The above statement was used to test the algorithm and verify it.

//Most  of the declarations are done below.
[m,n] = size(OrigImage);
StegImage = zeros(m,n);
siz = m*n;
p = zeros(1,siz);
ps = zeros(1,siz);
po = zeros(1,siz);

//Converting 2D image to 1D array.
k = 1
for i=1:m
    for j=1:n
        p(k) = OrigImage(i,j);
        k = k+1;
    end
end

//Calculating Pixel Difference.
d = zeros(1,siz);

for i=1:siz
    if(i == 1)
        d(i) = p(i);
    else
        d(i) = abs(p(i-1) - p(i));
    end
end

//Peak Point P is to be found.
//We use 'tabul' to get all the unique values and their frequencies.
//We use 'imhist' to get the Maximum Occurences of a particular unique value.
//This unique value is found using Tab and maxCounts and is assigned to P.

Tab = tabul(d);
[pixelCounts, grayLevels] = imhist(d); 
maxCounts = max(pixelCounts(:));

[a,b] = size(Tab);

P = 0;
for j=1:a
    if(Tab(j,2) == maxCounts)
        P = Tab(j,1);
    end
end

//Now that we have the P value. We shall proceed to take user input.
//According to the algorithm, the datasize has to be equal to the maxCount value.
//So we pad the rest of the array with 0s.
//We make sure to take input as a string in order to easily pad with 0s.
//Later we convert each charater to its correct double form using 'strtod'.
//'part' function allows us to access each character separately.
t = toc();
printf("\nThe Preprocessing Time: %d",t);
dataSize = maxCounts;
data = zeros(maxCounts);
x = input("Enter the data(0/1) in double quotes: ");
tic();
actLen = length(x);
for i=(length(x)+1):maxCounts
    x = x + "0";
end

for i=1:length(x)
    data(i) = strtod(part(x,i));
end

//Now that we have 1D array,P,data and maxCount we can go ahead and embed the data.
//This code is the implementation of the histogram modification algorithm that uses APD.
//We basically make sure to create an empty space in the histogram in order to embed our data.
//This is done by moving the rest of the values either to the left or right by 1 depending on different cases.
//The data is embedded when the difference value is equal to the peak point. Whether it is added to the current pixel value or subtracted depends upon the original image values.

  
pointer = 1;
for i=1:siz
    if(i == 1 | d(i) < P) then
        ps(i) = p(i);
    elseif(d(i) > P & p(i)>=p(i-1)) then
        ps(i) = p(i)+1;
    elseif(d(i) > P & p(i)<p(i-1)) then
        ps(i) = p(i)-1;
    elseif(d(i) == P & p(i)>=p(i-1)) then
        ps(i) = p(i) + data(pointer);
        pointer = pointer + 1;
    elseif(d(i) == P & p(i)<p(i-1)) then
        ps(i) = p(i) - data(pointer);
        pointer = pointer + 1;
    end
end

//Data has now been Embedded into the Image --> 1D Stego Image 'ps'.
//Converting the 1D stego image obtained into 2D in order to see the result.

k = 1;
for i=1:m
    for j=1:n
        StegImage(i,j) = ps(k);
        k = k + 1;
    end
end


//Now we get Original Image back from the Stego Image.
//In order to achieve this, we require the 1D stego image and P value.
//Basically we are reversing what we have done in the embedding process.

for i=1:siz
    if(i==1)
        po(i) = ps(i);
    elseif(abs(ps(i)-po(i-1)) > P & ps(i)<po(i-1))
        po(i) = ps(i)+1;
    elseif(abs(ps(i)-po(i-1)) > P & ps(i)>po(i-1))
        po(i) = ps(i)-1;
    else
        po(i) = ps(i);
    end
end

//We have gotten back the 1D Original Image 'po' using the P value and the Stego Image.

//Now that we are able to revert back to the original image 'po', the data can be extracted from the stego image.
//To do this we need 1D Original Image, 1D Stego Image, P value, maxCounts.
//We also take actLen which is the actual Length of the data so that the data can be read easily by the user.
//The differences between the current pixel of stego image and the previous pixel of original image are matched to see if they are equal to P value or P + 1. If so, then a bit 0 or 1 has been embedded respectively.

RCVdata = zeros(maxCounts);
ExtractedData = zeros(1,actLen);
pointer = 1;
for i=2:siz
    if(abs(ps(i)-po(i-1)) == P)
        RCVdata(pointer) = 0;
        pointer = pointer+1;
    elseif(abs(ps(i)-po(i-1)) == (P+1))
        RCVdata(pointer) = 1;
        pointer = pointer+1;
    end
end


//This loop is to make the extracted data more readable.
printf("\nThe data after Extraction is: ");
for i=1:actLen
    ExtractedData(1,i) = RCVdata(i);
    printf("%d",ExtractedData(i));
end
t = toc();
printf("\nThe Embedding/Extraction time: %d",t);
//Now we show you the Original Image and the Stego Image.

out = [uint8(OrigImage) uint8(StegImage)];
imshow(out);
