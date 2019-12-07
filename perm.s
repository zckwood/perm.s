/* Entry Points */
.global perm_sort
/* External Labels*/
.global printf
.global malloc
.global free


// perm_sort(void *a, int n, size_t msize)
// Args are in R0,R1, nd R2
//
// R0 is the pointer to list of strings (address)
// R1 is the number of strings
// R2 is the size of an address which is a 4
.data
.balign 4

 
    msize:		.word 4 	// msize = 4
    
	p_ptr: 		.word 0 	// char *p;
	q_ptr: 		.word 0   	// char *q;
	tmp_ptr: 	.word 0 	// char *tmp;
	
	flag:       .word 0     // int flag;

	fmt_str1:	.asciz 		"\n XX[%d]-->%s"  
	fmt_str2:	.asciz 		"\n p_ptr-->%s"  

.text
perm_sort: 	push 	{lr}				// Save Return point
			
			
		    N 		.req R10		// R10 contains N
		    A_ptr 	.req R9         // R9 contains A_Ptr (start of list)
		    P_ptr   .req R8         // R8 contains P_Ptr 
		    
		    mov     N,r1
		    mov     A_ptr,r0
		    
			
			// tmp  = malloc(msize);
			mov     r0,#4   // the number of bytes I want from malloc
			bl      malloc
			ldr     r2,=tmp_ptr
			str     r0,[r2]
			                // store the returned value in tmp_ptr
			                
			// Print out the list
			mov		r1,#0				// r1 is the index
	
			mov		r4,A_ptr
		
			ldr  	r0,fmt_str1_addr
			
			
prt_loop:	cmp 	r1,N
			bge		while_1
			ldr 	r2,[r4]
			push	{r0,r1,r2}  			// save things printf may change
			bl 		printf
			pop		{r0,r1,r2}				// restore things printf may change
			add 	r4,#4
			add		r1,#1
			b		prt_loop
			// end of the print loop
			
while_1:    
			// p= (char *)a + msize * (n-1); 
			sub r1,N,#1
			add P_ptr,A_ptr,r1, lsl #2
			
			
			// store in p_ptr
			ldr r1,=p_ptr
			str P_ptr,[r1]
			
			
			
while_2:    
		//	while((void*)p > a){
		    
		    ldr r0,=p_ptr
		    ldr r0,[r0]	    
		    cmp r0,A_ptr
		    ble while_2_end
		    
		//	    q = p - msize;
		    ldr r0,=p_ptr
		    ldr r0,[r0]	 
			sub r0,#4
			ldr r1,=q_ptr
			str r0,[r1]
			
			
			ldr r0,=q_ptr
		    ldr r0,[r0]	
		    ldr r0,[r0]
		    
			ldr r1,=p_ptr
		    ldr r1,[r1]	
		    ldr r1,[r1]
		     
		//		flag = strcmp(*(const char *const *)q, *(const char *const *)p);
		    bl  strcmp
		    cmp r0,#0
		    bgt while_2_end
		//		if (flag > 0)
		//				break;
		//		p = q;
		        
		        ldr r0,=q_ptr
		        ldr r0,[r0]
		        ldr r1,=p_ptr
		        str r0,[r1]
	    //  }
	        b while_2
	        
 while_2_end:           
			
			// if ((void*)p <= a) break;
		//	ldr r1,=a_ptr
		//    ldr r1,[r1]
		    
		    ldr r0,=p_ptr
		    ldr r0,[r0]	    
		    cmp r0,A_ptr
	        ble done
	        

    	// p= (char *)a + msize * (n-1); 
			sub r1,N,#1
			add P_ptr,A_ptr,r1, lsl #2
		
			
			// store in p_ptr
			ldr r1,=p_ptr
			str P_ptr,[r1]
			
		//while(p > q){
while_3:    
			ldr r0,=q_ptr
		    ldr r0,[r0]	
		    ldr r1,=p_ptr
		    ldr r1,[r1]	
		    cmp r1,r0
		    ble while_3_end
		//	flag = strcmp(*(const char *const *)q, *(const char *const *)p);
		//	
		//	if (flag > 0) break;
			ldr r0,=q_ptr
		    ldr r0,[r0]	
		    ldr r0,[r0]
		    
			ldr r1,=p_ptr
		    ldr r1,[r1]	
		    ldr r1,[r1]
		     
		//		flag = strcmp(*(const char *const *)q, *(const char *const *)p);
		    bl  strcmp
		    cmp r0,#0
			bgt while_3_end
			
		//	p = p - msize;
		// get value from p subtract 4 and store back    
			ldr r1,=p_ptr
		    ldr r0,[r1]	
		    sub r0,#4
		    str r0,[r1]
		    b while_3
		//}
while_3_end: 		
	
		 //   memcpy(tmp, p, msize);
		      ldr r0,=tmp_ptr
		      ldr r0,[r0]
		      ldr r1,=p_ptr
		      ldr r1,[r1]
		      mov r2,#4
		      bl  memcpy
		      
		 //   memcpy(p, q, msize);
		 	  ldr r0,=p_ptr
		      ldr r0,[r0]
		      ldr r1,=q_ptr
		      ldr r1,[r1]
		      mov r2,#4
		      bl  memcpy
		//    memcpy(q, tmp, msize);	
		      ldr r1,=tmp_ptr
		      ldr r1,[r1]
		      ldr r0,=q_ptr
		      ldr r0,[r0]
		      mov r2,#4
		      bl  memcpy
		/* flip a[k] through a[end] */
		//    q = q + msize;
			  ldr r1,=q_ptr
		      ldr r0,[r1]
		      add r0,#4
		      str r0,[r1]
		
		// p= (char *)a + msize * (n-1); 
			sub r1,N,#1
			add P_ptr,A_ptr,r1, lsl #2
			
			// store in p_ptr
			ldr r1,=p_ptr
			str P_ptr,[r1]
while_4:		
		//while( q < p){
		    ldr r0,=q_ptr
			ldr r0,[r0]
			ldr r1,=p_ptr
			ldr r1,[r1]
			cmp r0,r1
			bge while_4_end
			//swap(p, q);
		//	  memcpy(tmp, p, msize);
			  ldr r0,=tmp_ptr
		      ldr r0,[r0]
		      ldr r1,=p_ptr
		      ldr r1,[r1]
		      mov r2,#4
		      bl  memcpy
		//    memcpy(p, q, msize);
			  ldr r0,=p_ptr
		      ldr r0,[r0]
		      ldr r1,=q_ptr
		      ldr r1,[r1]
		      mov r2,#4
		      bl  memcpy
		//    memcpy(q, tmp, msize);
			  ldr r1,=tmp_ptr
		      ldr r1,[r1]
		      ldr r0,=q_ptr
		      ldr r0,[r0]
		      mov r2,#4
		      bl  memcpy
		//	q += msize;
			ldr r0,=q_ptr
			ldr r1,[r0]
			add r1,#4
			str r1,[r0]
		//	p -= msize;
			ldr r0,=p_ptr
			ldr r1,[r0]
			sub r1,#4
			str r1,[r0]
		//}     
		  b while_4
		
while_4_end:
		      
          b     while_1 
		    
			
done:			
			// free(tmp);
			ldr     r0,=tmp_ptr
			ldr     r0,[r0]
			bl		free
			
			pop 	{pc} 				// Return to calling function
			
			
fmt_str1_addr: .word fmt_str1
