private bool[][] sArr;
    private bool[][] vArr;
//
    private void findRect()
    {
      recArr = newArrayList();
      for (int i=0;i<bmp.Width; i++){
        for(int j=0; j<bmp.Height; j++)
          sArr[i][j]=false;
      }
      //
      for (int i=1;i<bmp.Width-1; i++) {
        for(int j=1; j<bmp.Height-1; j++) {
          if(vArr[i][j]) {
            rec= new Rectangle();
            rec.Y= j;
            rec.Height= j;
            rec.X= i;
            rec.Width= i;
            //
            if(findNext(i,j)) {
              if(rec.Width>0 && rec.Height>0) {
                rec.Height= rec.Height - rec.Y;
                rec.Width= rec.Width - rec.X;
                drawOneRec(rec);
                recArr.Add(rec);
              }
            }
            fnCount= 0;
          }
        }
      }
    }

    private int fnCount=0;

    private bool findNext(int i,int j)
    {
      fnCount++;
      if(fnCount> 10000)
      {
        //fnCount= 0;
        return true;
      }
      try
      {
        if(i<2||i>bmp.Width-2||j<2||j>bmp.Height-2)
        {
          //throw(newException("error"));
        }
        elseif (vArr[i][j] && !sArr[i][j])
        {
          if(j<rec.Y)
          {
            rec.Y=j;
          }
          if(j>rec.Height)
          {
            rec.Height=j;
          }
          if(i<rec.X)
          {
            rec.X=i;
          }
          if(i>rec.Width)
          {
            rec.Width=i;
          }
          //
          sArr[i][j]= true;
          //if(!vArr[i+1][j+1] || !vArr[i+1][j-1])
          if(vArr[i+1][j] && !sArr[i+1][j])
            findNext(i+1,j);
          if(vArr[i-1][j] && !sArr[i-1][j])
            findNext(i-1,j);
          if(vArr[i][j+1] && !sArr[i][j+1])
            findNext(i,j+1);
          if(vArr[i][j-1] && !sArr[i][j-1])
            findNext(i,j-1);
     
          //
          //findNext(i+1,j+1);
          //findNext(i-1,j-1);
          //findNext(i-1,j+1);
          //findNext(i+1,j-1);

       
        }
      }
      catch(Exception e)
      {
        //MessageBox.Show(e.Message);
        //returntrue;
       
      }
      returntrue;
  }