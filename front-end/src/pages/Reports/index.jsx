import React, { useEffect, useState } from 'react';
import Styles from "./reports.module.css";
import { useNavigate } from "react-router-dom";
import Cookies from "js-cookie"
import GenericReports from '../../components/ScientistReports/GenericReports';
import LeaderReports from '../../components/ScientistReports/leaderReports';
import CommanderReports from '../../components/ScientistReports/commanderReports';
import OfficerReport from '../../components/ScientistReports/OfficerReports';

const Reports = () => {
    const [userClass, setUserClass] = useState('');
    const [isLeader, setIsLeader] = useState(false);
    const navigate = useNavigate();

    useEffect(() => {
        const uClass = Cookies.get("userClass"); 
        setUserClass(uClass);

        if(uClass != "COMANDANTE" && uClass != "OFICIAL" && uClass != "CIENTISTA" ){
            navigate('/');
            console.log("Erro");
        }

        setIsLeader(Cookies.get("userFaction") != "undefined")
    }, []);

    const handleLogoff = () => {
        document.cookie = "";
        navigate('/');
    };

    const leaderReports = ()=>(
        <>
            <LeaderReports/>
        </>
    );

    const commanderReports = ()=>(
        <>
            <CommanderReports/>
        </>
    );

    const scientistReports = ()=>(
        <>
            <GenericReports/>
        </>
    );
    const Officer = ()=>(
        <>
            <OfficerReport/>
        </>
    );
    return (
        <div className={Styles.container}>
            <div className={Styles.user}>
                <h2>{userClass === "CIENTISTA" ? "Dr(a)" : userClass} {Cookies.get("userName")}, estes são seus relatórios</h2>
                <div className={Styles.actions}>
                    <button onClick={()=>{navigate("/overview")}}>Overview</button>
                    <button onClick={handleLogoff}>Logoff</button>
                </div>
            </div>
            <div className={Styles.dashboard}>
                <div className={Styles.reports}>
                    {isLeader && leaderReports()}
                    {userClass === "COMANDANTE" && commanderReports()}
                    {userClass === "CIENTISTA" && scientistReports()}
                    {userClass === "OFICIAL" && Officer()}
                </div>
            </div>
        </div>
    );
};

export default Reports;