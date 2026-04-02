package com.tyss.repo;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.tyss.entity.Course;

public interface CourseRepo extends JpaRepository<Course, Integer> {

	Integer countByUserUid(Integer uid);
	
	List<Course> findByUserUid(Integer uid);
	
	@Query("SELECT c.name FROM Course c WHERE c.user.uid =?1 ORDER BY c.createdDate DESC LIMIT 4")
	List<String> getRecentCourses(Integer uid);
	
}
