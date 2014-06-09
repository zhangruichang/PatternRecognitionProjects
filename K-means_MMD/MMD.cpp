#include <iostream>
#include <fstream>
using namespace std;
double Distance(double *x,double *y,int n)//Euclean distance
{
	int i;
	double distance=0;
	for(i=0;i<n;i++)
	{
		distance+=(x[i]-y[i])*(x[i]-y[i]);
	}
	return sqrt(distance);
}
int main()
{
	int i,j,k;//for loop
	int dim=4;
	int n=150;
	double t=0.5;//threshold for initial cluster
	//double d;//maxmin distance
	double a;//arithmetic mean for each pair of cluster centers
	int c;//cluster number
	//int w[c][dim];
	double **w=new double*[150];
	double **x=new double*[n];
	bool **d=new bool*[150];
	for(i=0;i<150;i++)
	{
		w[i]=new double[dim];
		d[i]=new bool[n];
	}
	for(i=0;i<n;i++)
		x[i]=new double[dim];
	

	for(i=0;i<150;i++)
		for(j=0;j<n;j++)
			d[i][j]=false;
	//int x[n][dim];
	int maxdis_i,mindis_j;
	int clusteri;//which cluster
	int dist_num;
	double maxdis,mindis;
	//bool d[c][n];
	ifstream infile("iris.dat");
	j=0;
	while(infile.peek()!=EOF)
	{
		i=0;
		infile>>x[j][i];
		infile>>x[j][++i];
		infile>>x[j][++i];
		infile>>x[j][++i];
		infile>>clusteri;
		//real_d[clusteri][j]=true;
		j++;
	}
	infile.close(); 

	for(i=0;i<dim;i++)
		w[0][i]=x[0][i];
	c=1;
	ofstream outfile("MMD");
	outfile<<"0 ";
	while(1)
	{
		maxdis=0;
		maxdis_i=0;
		for(i=0;i<n;i++)
		{
			mindis=Distance(x[i],w[0],dim);
			for(j=1;j<c;j++)
			{
				if(mindis>Distance(x[i],w[j],dim))
					mindis=Distance(x[i],w[j],dim);
			}
			if(maxdis<mindis)
			{
				maxdis=mindis;
				maxdis_i=i;
			}
		}
		dist_num=0;
		a=0;
		for(i=0;i<c;i++)
		{
			for(j=i+1;j<c;j++)
			{
				a+=Distance(w[i],w[j],dim);
				dist_num++;
			}
		}
		a/=dist_num;
		if(maxdis<t*a)
			break;
		outfile<<maxdis_i<<" ";
		for(i=0;i<dim;i++)//new cluster
			w[c][i]=x[maxdis_i][i];
		c++;
	}
	cout<<c<<endl;
	outfile<<endl;
	for(i=0;i<n;i++)
	{
		mindis=Distance(x[i],w[0],dim);
		mindis_j=0;
		for(j=1;j<c;j++)
		{
			if(mindis>Distance(x[i],w[j],dim))
			{
				mindis=Distance(x[i],w[j],dim);
				mindis_j=j;
			}
		}
		d[mindis_j][i]=true;
	}
	int *c_num=new int[c];

	//initial c_num[] and w[][] with 0
	for(i=0;i<c;i++)
	{
		c_num[i]=0;
		for(j=0;j<dim;j++)
			w[i][j]=0;
	}

	//recomputer cluster center
	for(i=0;i<n;i++)
	{
		for(j=0;j<c;j++)
		{
			if(d[j][i]==true)
			{
				for(k=0;k<dim;k++)
					w[j][k]+=x[i][k];
				c_num[j]++;
			}
		}
	}
	for(j=0;j<c;j++)
	{
		for(k=0;k<dim;k++)
			w[j][k]/=c_num[j];
	}


	cout<<"MMD"<<endl;
	//outfile<<"iterative_count: "<<iterative_count<<endl;
	int cluster_seq[3]={0,100,50};
	double cluster_error[3]={0,0,0},total_error=0;
	for(i=0;i<c;i++)
	{
		outfile<<"cluster "<<i<<endl;
		outfile<<"center: ";
		for(j=0;j<dim;j++)
			outfile<<w[i][j]<<" ";
		outfile<<endl;
		for(j=0;j<n;j++)
		{
			if(d[i][j])
			{
				if(j>=cluster_seq[i]+50||j<cluster_seq[i])
				{
					cluster_error[i]++;
					total_error++;
				}
				outfile<<j<<" ";
				for(k=0;k<dim;k++)
					outfile<<x[j][k]<<" ";
				outfile<<endl;
			}
		}
		outfile<<"cluster_error: "<<cluster_error[i]/50<<endl;
	}
	outfile<<"total_error: "<<total_error/n<<endl;
	outfile.close();


	for(i=0;i<150;i++)
		delete []w[i];
	for(i=0;i<n;i++)
		delete []x[i];
	delete []w;
	delete []x;
	delete []c_num;
	system("pause");
}