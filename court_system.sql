CREATE DATABASE court_system;
USE court_system;

CREATE TABLE parties (
    party_id INT AUTO_INCREMENT PRIMARY KEY,
    party_type ENUM('PERSON','ORGANIZATION') NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NULL,
    inn VARCHAR(20),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50) UNIQUE,
    address VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_party (full_name, date_of_birth, party_type)
);

CREATE TABLE court_districts (
    district_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    region VARCHAR(255)
);

CREATE TABLE judges (
    judge_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    district_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    termination_date DATE,
    email VARCHAR(255),
    phone VARCHAR(50),
    FOREIGN KEY (district_id) REFERENCES court_districts(district_id)
);

CREATE TABLE case_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
   category_name VARCHAR(255) UNIQUE NOT NULL,
    category_description TEXT
);

CREATE TABLE court_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    case_number VARCHAR(50) UNIQUE NOT NULL,
    category_id INT NOT NULL,
    district_id INT NOT NULL,
    filing_date DATE NOT NULL,
    close_date DATE,
    result ENUM('PLAINTIFF_WIN','DEFENDANT_WIN','PARTIAL','DISMISSED','OTHER'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES case_categories(category_id),
    FOREIGN KEY (district_id) REFERENCES court_districts(district_id),
    CHECK (close_date IS NULL OR close_date >= filing_date)
);

CREATE TABLE case_participants (
    case_id INT NOT NULL,
    party_id INT NOT NULL,
    role ENUM('PLAINTIFF','DEFENDANT','LAWYER','PROSECUTOR','THIRD_PARTY') NOT NULL,
    PRIMARY KEY (case_id, party_id, role),
    FOREIGN KEY (case_id) REFERENCES court_cases(case_id) ON DELETE CASCADE,
    FOREIGN KEY (party_id) REFERENCES parties(party_id)
);

CREATE TABLE case_judges (
    case_id INT NOT NULL,
    judge_id INT NOT NULL,
    judge_role ENUM('MAIN','ASSISTANT') DEFAULT 'MAIN',
    assigned_date DATE NOT NULL,
    decision_date DATE,
    PRIMARY KEY (case_id, judge_id),
    FOREIGN KEY (case_id) REFERENCES court_cases(case_id) ON DELETE CASCADE,
    FOREIGN KEY (judge_id) REFERENCES judges(judge_id),
    CHECK (decision_date IS NULL OR decision_date >= assigned_date)
);

CREATE TABLE documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT NOT NULL,
    judge_id INT,
    doc_type ENUM('CLAIM','MOTION','DECISION','ORDER','OTHER') NOT NULL,
    doc_title VARCHAR(255) NOT NULL,
    doc_date DATE NOT NULL,
    registration_date DATE NOT NULL,
    decision_result ENUM('POSITIVE','NEGATIVE','NEUTRAL'),
    is_final BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES court_cases(case_id) ON DELETE CASCADE,
    FOREIGN KEY (judge_id) REFERENCES judges(judge_id),
    CHECK (registration_date >= doc_date)
);
