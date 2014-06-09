#include <iostream>
#include <fstream>
#define Max 1000000000
#define Min 0
using namespace std;
double Distance(double *x,double *y,int n)//Euclean distance
{
	int i;
	double distance=0;
	for(i=0;i<n;i++)
	{
		if(i==148)
			int j=0;
		distance+=(x[i]-y[i])*(x[i]-y[i]);
	}
	return sqrt(distance);
}
bool Converge(double** w,double** new_w,int c,int dim)//wheather is converged 
{
	double sum=0;
	int i;
	for(i=0;i<c;i++)
		sum+=Distance(w[i],new_w[i],dim);
	
	if(sum<1e-7)
		return true;
	else
		return false;
}
int main()
{
	//read data
	int i,j,k;
	
	const int dim=4;//dimesion 
	const int n=150;//number of data sets
	int m;//
	const int c=3;//number of cluser
	double x[n][dim];//data
	bool d[c][n];// which cluster the data is
	bool initial_center[n];
	double **w=new double*[c],**new_w=new double*[c];
	for(i=0;i<c;i++)
	{
		w[i]=new double[dim];
		new_w[i]=new double[dim];
	}
	
	//cluster center
	//double new_w[c][dim];//updated cluster center
	
	//double total_x[c][dim];//temper varible for computing new_w[][]
	//clustering
	
	
	int current_c;//initilal current center number
	int candidate_centeri;
	double mindis;//min distance to decide which cluster
	int total_num;//the sum of data in cluster i
	int mindis_j;//closest cluster j
	int maxdis_j;
	double maxdis;// 
	
	int clusteri;
	int real_d[c][n];
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
		real_d[clusteri][j]=true;
		j++;
	}
	infile.close();
	//n=j;
	//dim=i+1;
	for(i=0;i<c;i++)
	{
		for(j=0;j<n;j++)
		{
			initial_center[j]=false;
			d[i][j]=false;
			real_d[i][j]=false;
		}
	}
	
	//initila cluser center(better with maximum-minimun algorithm)
	//set x[0] as cluster 1 center
	for(i=0;i<dim;i++)		
		new_w[0][i]=x[0][i];
	initial_center[0]=true;
	current_c=1;
	cout<<"C_means"<<endl;
	ofstream outfile("C_means_result");
	/*
	outfile<<"0"<<" ";
	while(current_c<c)
	{
		maxdis=0;
		maxdis_j=0;
		for(i=0;i<n;i++)//traverse n data
		{
			if(!initial_center[i])//not as cluster center
 			{
			//maxdis=Distance(x[0],w[i-1])
				mindis=Distance(x[i],new_w[0],dim);
				for(j=1;j<current_c;j++)
				{
					if(mindis>Distance(x[i],new_w[j],dim))
					{
						mindis=Distance(x[i],new_w[j],dim);
						//candidate_centeri=i;
					}
				}
				if(maxdis<mindis)
				{
					maxdis=mindis;
					maxdis_j=i;
				}
			}
		}
		outfile<<maxdis_j<<" ";
		for(i=0;i<dim;i++)
			new_w[current_c][i]=x[maxdis_j][i];
		initial_center[maxdis_j]=true;
		current_c++;
	}
	*/
	//random
	
	int rand_i;
	for(i=0;i<c;i++)
	{
		rand_i=rand()%n;
		for(j=0;j<dim;j++)
			new_w[i][j]=x[rand_i][j];
		initial_center[rand_i]=true;
		current_c++;
	}
	
	//output initial cluster center



	outfile<<endl;
	for(i=0;i<c;i++)
	{
		outfile<<"cluster "<<i<<endl;
		for(j=0;j<dim;j++)
			outfile<<new_w[i][j]<<" ";
		outfile<<endl;
	}
	int iterative_count=0;
	//iterative for clustering
	while(!Converge(w,new_w,c,dim))
	{
		//update w;
		for(i=0;i<c;i++)
			for(j=0;j<dim;j++)
				w[i][j]=new_w[i][j];
		//compute d_ij
		for(i=0;i<n;i++)
		{
			mindis=Distance(x[i],w[0],dim);
			mindis_j=0;
			for(j=1;j<c;j++)
			{
				if(i==3&&j==1)
					int zhang=1;
				if(mindis>Distance(x[i],w[j],dim))
				{
					mindis=Distance(x[i],w[j],dim);
					mindis_j=j;
				}
			}
			d[mindis_j][i]=true;
			for(j=0;j<c;j++)
			{
				if(j!=mindis_j)
					d[j][i]=false;
			}
		}			
		
		/*for(i=0;i<c;i++)
		{
			mindis=Distance(x[0],w[i]);
			for(j=1;j<n;j++)
			{
				if(mindis>Distance(x[j],w[i]))
				{
					mindis=Distance(x[j],w[i]);
					d[i][j]=true;
				}
			}
			
		}*/
		//modify cluster center
		
		/*for(i=0;i<c;i++)
			for(j=0;j<dim;j++)
				total_x[i][j]=0;*/
			
		for(i=0;i<c;i++)
		{
			for(j=0;j<dim;j++)
				new_w[i][j]=0;
			total_num=0;
			for(j=0;j<n;j++)
			{
				if(d[i][j])
				{
					for(k=0;k<dim;k++)
						//total_x[i][k]+=x[j][k];
						new_w[i][k]+=x[j][k];
					total_num++;
				}
			}
			for(k=0;k<dim;k++)
				new_w[i][k]/=total_num;
		}
		iterative_count++;
	}//end of iterative
	//output
	outfile<<"iterative_count: "<<iterative_count<<endl;
	int cluster_seq[3]={50,0,100};
	double cluster_error[3]={0,0,0},total_error=0;
	for(i=0;i<c;i++)
	{
		outfile<<"cluster "<<i<<endl;
		outfile<<"center: ";
		for(j=0;j<dim;j++)
			outfile<<new_w[i][j]<<" ";
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
	for(i=0;i<c;i++)
	{
		delete []w[i];
		delete []new_w[i];
	}
	delete []w;
	delete []new_w;
	outfile.close();
	system("pause");
}