# Reconstituted-Morphogen-Gradient-Analysis
Used to quantify the 1D and 2D gradients of reconstituted morphogen gradients.

Calculating Background
1. Run CalcBackground to average the control images taken
      Media alone: accounts for media autofluorescence
      Fluorecene cadaverine: estimates flourescent differences due to the well morphology
2. Save all files created in Step 5 as Background.mat

*Background.mat files can be used interchangeably between 1D and 2D gradients

2D Gradients
1. Use a cell tracking program to track individual sender cells and generate a matrix of tracked cell positions
2. Determine the index of the sender cell in a matrix that you want to be analyzed
3. Run ExtractSenderPos using the index of the sender cell
      This will extract the tracked positions of a single sender cell from the matrix 
4. Repeat step 3 for every sender cell you want to analyze
5. Run Gradient2D_analysis on as many single senders as needed
6. Run Gradient2D_averagepos to average out all the data

1D gradients
1. Run Gradient1D_analysis on as many 1D gradient images as needed
2. Run Gradient1D_averagepos to average out all the data


