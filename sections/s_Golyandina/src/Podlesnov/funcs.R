library(combinat)
library(readxl)
library(knitr)
library(xtable)
#######################
tab1..<-matrix(rep(1,60),ncol=10)
BB<-apply(tab1..,2,function(x){
  list(apply(combn(which(x!=0)-1,3),2,function(y)paste(y,collapse="")) )  })
BB<-lapply(BB,function(x)x[[1]]);BB
BB<-apply(tab1.,2,function(x){
  apply(combn(which(x!=0)-1,3),2,function(y)paste(y,collapse=""))   })
u1<-BB[[1]][1];u1

Proc2<-function(u1,U.1,BB)
  # дизайны для таблицы
{  # u1<-"012"; u2<-"023"; u3<-"124"
  K.2<-list();bc<-NULL
  for(u2 in U.1)
  {
    # u2<-U.1[2];u2
    # print(u2)
    y<-c(u1,u2); W<-HowMuchD(y,LP,BB[[3]])
    U.2<-W[[1]];U.2;jj<-W[[2]];jj
    if(length(U.2)==0) res3<-NA else 
      #u3<-U.2[1];u3
    {aa<-0;
    for (u3 in U.2)
    { # u3<-U.2[1];u3
      y<-c(u1,u2,u3);y;
      W<-HowMuchD(y,LP,BB[[4]]);U.3<-W[[1]];U.3;j3<-W[[2]];j3
      
      if(length(j3)==1) {
        xx<-permn(setdiff(LP[[j3]],y));xx
        cond<-unlist(lapply(xx,function(x)x[1] %in% U.3))
        
        res3<-lapply(xx[cond],function(x2)c(y,x2))
        
        K.2<-c(K.2,res3); bc<-c(bc,1)
        #print(length(K.2))
      } else  
        for (u4 in U.3)
        { # u4<-U.3[1];u4
          y<-c(u1,u2,u3,u4);y;
          W<-HowMuchD(y,LP,BB[[5]]);U.4<-W[[1]];U.4;j4<-W[[2]];j4
          if(length(j4)==1) {
            res3<-lapply(permn(setdiff(LP[[j4]],y)),
                         function(x2)c(y,x2))
            
            K.2<-c(K.2,res3);bc<-c(bc,2)#print(length(K.2))
          } else 
            for (u5 in U.4)
            {
              y<-c(u1,u2,u3,u4,u5);y;
              W<-HowMuchD(y,LP,BB[[6]]);U.5<-W[[1]];U.5;j5<-W[[2]];j5
              if(length(j5)==1) {
                res3<-lapply(permn(setdiff(LP[[j5]],y)),
                             function(x2)c(y,x2))
                
                K.2<-c(K.2,res3);bc<-c(bc,3)#print(length(K.2))
              } else {
                for (u6 in U.5)
                {
                  y<-c(u1,u2,u3,u4,u5,u6);y;
                  W<-HowMuchD(y,LP,BB[[7]]);U.6<-W[[1]];U.6;
                  j6<-W[[2]];j6
                  
                  if(length(j6)==1) {
                    res3<-lapply(permn(setdiff(LP[[j6]],y)),
                                 function(x2)c(y,x2))
                    
                    K.2<-c(K.2,res3);bc<-c(bc,4)#print(length(K.2))
                  } else {
                    for (u7 in U.6)
                    {
                      y<-c(u1,u2,u3,u4,u5,u6,u7);y;
                      W<-HowMuchD(y,LP,BB[[8]]);U.7<-W[[1]];U.7;
                      j7<-W[[2]];j7
                      
                      if(length(j7)==1) {
                        res3<-lapply(permn(setdiff(LP[[j7]],y)),
                                     function(x2)c(y,x2))
                        
                        K.2<-c(K.2,res3);bc<-c(bc,5)#print(length(K.2))
                      } 
                    } #u7
                  } 
                  
                } #u6
              } 
              
            } #u5 
          
          
        }#u4
      
    }
    } #aa
    #print(length(K.2))
  }#u2
  list(K.2,bc)
} # proc


# ttt<-sapply(BB[[1]],function(u1)
#   {
#   print(u1);
#   U.1<-setdiff(BB[[2]],c(u1,Opp_b(u1)));U.1 #u2<-U.1[1];u2
#   length(Proc2(u1,U.1,BB)[[1]])
#   })

TransB<-function(B){ paste(as.character(sort(B)),collapse="")}; TransB(B)
##########################
Test2D<-function(dd){d<-strsplit(dd,"[.]")[[1]]
tt<-TestD(Pair,t(sapply(d,function(y)as.numeric(substring(y,1:3,1:3)))))
ifelse(identical(rep(2,10),tt[[1]]) & identical(rep(5,5),tt[[2]]),1,0)}
#######################
Test3D<-function(d){
  tt<-TestD(Pair,t(sapply(d,function(y)as.numeric(substring(y,1:3,1:3)))))
  ifelse(identical(rep(2,10),tt[[1]]) & identical(rep(5,5),tt[[2]]),1,0)}
##############################
# lapply(LL,function(D)TestD(Pair,D))
# D<-LL[[2]];D
SubstitutionD2<-function(tab1.,D)
{
  OmD<-apply(D,1,function(x)TransB(x))
  hj<-EEE(D);hj; x<-seq(2)
  HJ<-lapply(hj,function(x) sapply(x,function(y)TransB(D[y,]) ))
  PD<-list()
  for (i1 in seq(length(HJ[[1]])))
  {
    #print(paste("i1",i1,sep="="))
    x1<-HJ[[1]][i1];x1
    WQ1<-setdiff(HJ[[2]],x1);WQ1
    #print(c(x1=x1,WQ1=WQ1))
    for(i2 in seq(length(WQ1)))
    { #print(i2)
      x2<-WQ1[i2];x2
      WQ2<-setdiff(HJ[[3]],c(x1,x2));WQ2
      #print(c(x2=x2,WQ2=WQ2))
      for(i3 in seq(length(WQ2)))
      { #print(i3)
        x3<-WQ2[i3];
        WQ3<-setdiff(HJ[[4]],c(x1,x2,x3));WQ3
        #print(c(x3=x3,WQ3))
        for(i4 in seq(length(WQ3)))
        { #print(paste("i4",i4,sep="="))
          x4<-WQ3[i4];
          WQ4<-setdiff(OmD,c(x1,x2,x3,x4));WQ4
          print(c(xx=c(x1,x2,x3,x4),WQ4=WQ4))
          res1<-unlist(lapply(permn(seq(6)),function(x)paste(c(x1,x2,x3,x4,WQ4[x]),collapse=".")))
          
          PD<-c(PD,res1)
        }#i4
      }#i3
    } # i2
  } #i1
  PD
}# end Substitution



##### раннжирование наблюдений по интервалам
RangeBlocks<-function(x,K)
{
  R<-max(x)-min(x);R
  h<-R/K;h
  br<-seq(min(x),max(x),by=h)
  L<-lapply(seq(K),function(k){
    which(x>=br[k] & x<br[k+1])
  })
  L
}

##### раннжирование наблюдений по интервалам
RangeBlocksBr<-function(x,br)
{
  K<-length(br)-1
  L<-lapply(seq(K),function(k){
    which(x>=br[k] & x<br[k+1])
  })
  L
}

############
###################
OT18<-function(t,U)
{# set of intersecting lines
  
  U[,which(apply(U,2,function(x)length(intersect(x,t)))==1)]
}

# t<-seq(3)
# U<-combn(7,3)
# OT18(t,U)

#############
#Через две пересекающиеся прямые проводим третью.
LineP<-function(t1,t2){
  a<-intersect(t1,t2);b<-unique(c(t1,t2)) ;b
  sort(c(a,setdiff(seq(7),b)))
}
t1<-c(1,2,3); t2<-c(2,4,6)
t3<-LineP(t1,t2); t3
###########
#Перечисляем всевозможные блоки, имеющие с заданными двумя  блоками по одному общему элементу.


##################
OTT8<-function(t,s)
{
  U1<-OT18(t,U);U1
  U2<-OT18(s,U1);U2
  t0<-intersect(s,t)
  U2[,which(apply(U2,2,function(x) !(t0 %in% x)))]
}

#U.c<-OTT8(c(1,2,3),c(2,4,6));U.c

####

#Делим это множество на четное и нечетное подмножество. 


#############


DivU.c<-function(U.c, tt)
{
  t<-U.c[,1]; t
  U1<-cbind(t0=t,apply(tt,2,function(s)LineP(t,s)));U1
  U2<-NULL
  U.c
  for(i in c(2:ncol(U.c)))
  {
    z<-apply(U1,2,function(x)  sum((x-U.c[,i])^2));z
    if(!(0 %in% z ))U2<-cbind(U2,U.c[,i]) 
  }
  list(U1,U2)
}


# tt<-cbind(t1,t2,LineP(t1,t2))
# DivU.c(U.c, tt)

####################

PermD<-function(U)
  
{
  #tab<-matrix(rep(1,49),ncol=7)
  
  Q<-apply(U,2,function(t1)
  {
    
    U.b<-OT18(t1,U);U.b
    apply(U.b,2,function(t2)
      
    {
      U.c<-OTT8(t1,t2);U.c
      
      t3<-LineP(t1,t2);t3
      
      tt<-cbind(t1,t2,t3);tt
      UU<-DivU.c(U.c,tt)
      UU
      
      lapply(UU,function(K)
      {
        ttt<-cbind(t3,K);ttt
        L.<-lapply(permn(5),function(x)cbind(t1,t2,ttt[,x]))
        
        L.  
      })
    })
  })
  
  QQ<-list()
  for(i1 in seq(length(Q)))
  {
    m1<-length(Q[[i1]]);m1
    if(m1>0)
      for(i2 in seq(m1))
      {
        m2<-length(Q[[i1]][[i2]]);m2
        if(m2>0)for(i3 in seq(m2))
          QQ<-c(QQ,Q[[i1]][[i2]][[i3]])
      }}
  QQ
  
}
#-----------------------------
#QQ<-PermD(U)

#c(30*factorial(7),length(QQ))
######################

Est<-function(dat)
{
  V<-rowSums(dat,na.rm=TRUE);V
  B<-colSums(dat,na.rm=TRUE);B
  T.<-apply(dat,1,function(x){
    sum(B[which(!is.na(x))])
  });T.
  mu<-mean(as.vector(dat),na.rm=TRUE);mu
  list(V=V,B=B,T.=T.,mu=mu)
}
#est<-Est(dat)
# ```
# 
# 
# Оценки

# $$
#   \hat  v_l=\frac{kV_l-T_l}{\lambda v}, 	\hat {b}_j=\frac {B_j} k -\frac 1 k \sum\limits_{i\in b_j} \hat v_i -\hat \mu\,.
# $$
#   
####################

VB<-function(est,param.,dat)
{
  v.<-(param.["k"]*est$V-est$T.)/param.["lam"]/param.["v"];v.
  a<-apply(dat,2,function(x){
    sum(v.[which(!is.na(x))])
  });a
  b.<-est$B/param.["k"]-  a/param.["k"] -est$mu; b.
  list(v.=v.,b.=b.,a=a)
}




# $$
#   \sum\limits_{(i,j)}(x_{ij}-\hat{\mu})^2=S^2_v+S^2_b+S^2_e,~~\mbox{где}
# $$
#   
#   
#   
#   $$
#   S_v^2=\sum\limits_{(ij)}\left(\hat v_i-\frac{1}{k}\sum\limits_{l\in \beta_j}\hat v_l\right)^2=\frac{\lambda v}{k}\sum\limits_{i=1}^v\hat v_i^2,~~~df_v=v-1,
# $$
  
  
#   
#   
#   
#   $$ 
#   S_b^2=\sum\limits_{j=1}^b k\left( \frac{B_j}{k}-\hat{\mu}^2\right)^2, ~~~df_b=b-1;
# $$
#   
#   
  
  
#   
#   $$
#   S_e^2=\sum\limits_{(i,j)}\left(x_{ij} - \hat v_i +\frac 1 k \sum\limits_{l\in \beta_j}\hat v_l-\frac{B_j}k\right)^2,\\~~~ df_e=bk-1-(v-1)-(b-1)=bk-v-b+1\,.
# $$
#   


SS<-function(dat,est,param.,vb)
{
  S<-sum((as.vector(dat)-est$mu)^2,na.rm=TRUE);S
  Sv2<-as.numeric(param.["lam"]*param.["v"]/param.["k"]*sum(vb$v.^2));Sv2
  
  Sb2<-param.["k"]*sum((est$B/param.["k"]-est$mu)^2);Sb2
  Se2<-0
  for (i in seq(nrow(dat)))
    for(j in seq(ncol(dat)))
    {
      if(!is.na(dat[i,j]))
        Se2<-Se2+(dat[i,j]-vb$v.[i]+vb$a[j]/param.["k"]-est$B[j]/param.["k"])^2
    }
  Se2
  c(S,Se2+Sv2+Sb2)
  
  v<-param.["v"]; b<-param.["b"]; k<-param.["k"]
  Fv<-Sv2/(v-1)/Se2*(b*k-v-b+1)
  p.value.v<-1-pf(Fv,v-1,b*k-v-b+1);p.value.v
  
  Fb<-Sb2/(b-1)/Se2*(b*k-v-b+1)
  p.value.b<-1-pf(Fb,b-1,b*k-v-b+1);p.value.b
  c(p.value.v=as.numeric(p.value.v),p.value.b=as.numeric(p.value.b))
}
#SS(dat,est,param.,vb)




##############

Param<-function(dat)
{
  v<-nrow(dat);v;
b<-ncol(dat);b
k<-apply(dat,2,function(x)length(na.omit(x)));k;k<-k[1];k
r<-apply(dat,1,function(x)length(na.omit(x)));r;r<-r[1];r
Lam<-apply(combn(nrow(dat),2),2,function(x) 
  apply(dat,2,function(y){
    ifelse( length(intersect(x, which(!(is.na(y)))))==2 ,1,0)
  })
)
Lam
lam<-colSums(Lam)[1];lam
c(v=v,b=b,r=r,k=k,lam=lam)
}

##############

Form<-function(S1,S2,y)
{
  sapply(seq(length(S1)),function(i)
    sapply(seq(length(S2)),function(j)
    {
      y.<-y[intersect(S1[[i]],S2[[j]])]
      ifelse(length(y.)>0,mean(y.),NA)
    }))
}


#######
Result2<-function(S1,S2,Tab,D){
  
  v<-length(unique(as.vector(D)));v
  k<-ncol(D); b<-nrow(D);c(k,b)
  dat<-matrix(rep(NA,v*b),ncol=b);dat
  for(i in seq(k))for(j in seq(b))
  {#print(c(i,j));
    dat[D[j,i],j]<-Tab[D[j,i],j]}
  
  #xtable(t(dat ),digits=0)
  param.<-Param(dat)
  est<-Est(dat)
  vb<-VB(est,param.,dat)
  SS(dat,est,param.,vb)
}
